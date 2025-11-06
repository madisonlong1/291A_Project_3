module Api
  class UpdatesController < ApplicationController
    SECRET_KEY = Rails.application.credentials.secret_key_base || 'dev_key'

    # GET /api/conversations/updates?userId=<id>&since=<timestamp>
    def conversations
      user_id = params[:user_id].to_i
      since = params[:since].present? ? Time.parse(params[:since]) : 1.hour.ago

      # Extract user from JWT token
      current_user = extract_user_from_token
      return render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user

      # Get conversations where user is initiator OR assigned expert
      conversations = Conversation.where(
        "initiator_id_id = ? OR assigned_expert_id_id = ?",
        user_id,
        user_id
      ).where("updated_at >= ?", since)

      # Build response with unreadCount for each conversation
      response_data = conversations.map do |conv|
        unread_count = Message.where(
          conversation_id: conv.id,
          is_read: false
        ).where.not(sender_id: user_id).count

        {
          id: conv.id.to_s,
          title: conv.title,
          status: conv.status,
          questionerId: conv.initiator_id_id.to_s,
          questionerUsername: User.find(conv.initiator_id_id).username,
          assignedExpertId: conv.assigned_expert_id_id.present? ? conv.assigned_expert_id_id.to_s : nil,
          assignedExpertUsername: conv.assigned_expert_id_id.present? ? User.find(conv.assigned_expert_id_id).username : nil,
          createdAt: conv.created_at.iso8601,
          updatedAt: conv.updated_at.iso8601,
          lastMessageAt: conv.last_message_at&.iso8601,
          unreadCount: unread_count
        }
      end

      render json: response_data, status: :ok
    end

    # GET /api/messages/updates?userId=<id>&since=<timestamp>
    def messages
      user_id = params[:user_id].to_i
      since = params[:since].present? ? Time.parse(params[:since]) : 1.hour.ago

      # Extract user from JWT token
      current_user = extract_user_from_token
      return render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user

      # Get conversations where user is involved
      user_conversations = Conversation.where(
        "initiator_id_id = ? OR assigned_expert_id_id = ?",
        user_id,
        user_id
      ).pluck(:id)

      # Get messages in those conversations since timestamp
      messages_data = Message.where(
        conversation_id: user_conversations
      ).where("created_at >= ?", since).map do |msg|
        sender = User.find(msg.sender_id)
        {
          id: msg.id.to_s,
          conversationId: msg.conversation_id.to_s,
          senderId: msg.sender_id.to_s,
          senderUsername: sender.username,
          senderRole: msg.sender_role,
          content: msg.content,
          timestamp: msg.created_at.iso8601,
          isRead: msg.is_read
        }
      end

      render json: messages_data, status: :ok
    end

    # GET /api/expert-queue/updates?expertId=<id>&since=<timestamp>
    def expert_queue
      expert_id = params[:expert_id].to_i
      since = params[:since].present? ? Time.parse(params[:since]) : 1.hour.ago

      # Extract user from JWT token
      current_user = extract_user_from_token
      return render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user

      # Get waiting conversations (status = 'waiting')
      waiting_conversations = Conversation.where(status: 'waiting')
                                          .where("updated_at >= ?", since)

      # Get assigned conversations for this expert (status = 'active' and assigned to this expert)
      assigned_conversations = Conversation.where(
        status: 'active',
        assigned_expert_id_id: expert_id
      ).where("updated_at >= ?", since)

      # Build response
      waiting_data = waiting_conversations.map { |conv| build_conversation_response(conv, expert_id) }
      assigned_data = assigned_conversations.map { |conv| build_conversation_response(conv, expert_id) }

      response_data = {
        waitingConversations: waiting_data,
        assignedConversations: assigned_data
      }

      render json: response_data, status: :ok
    end

    private

    def extract_user_from_token
      token = request.headers['Authorization']&.split(' ')&.last
      return nil unless token

      begin
        payload = JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' }).first
        User.find(payload['user_id'])
      rescue
        nil
      end
    end

    def build_conversation_response(conv, expert_id)
      unread_count = Message.where(
        conversation_id: conv.id,
        is_read: false
      ).where.not(sender_id: expert_id).count

      {
        id: conv.id.to_s,
        title: conv.title,
        status: conv.status,
        questionerId: conv.initiator_id_id.to_s,
        questionerUsername: User.find(conv.initiator_id_id).username,
        assignedExpertId: conv.assigned_expert_id_id.present? ? conv.assigned_expert_id_id.to_s : nil,
        assignedExpertUsername: conv.assigned_expert_id_id.present? ? User.find(conv.assigned_expert_id_id).username : nil,
        createdAt: conv.created_at.iso8601,
        updatedAt: conv.updated_at.iso8601,
        lastMessageAt: conv.last_message_at&.iso8601,
        unreadCount: unread_count
      }
    end
  end
end
