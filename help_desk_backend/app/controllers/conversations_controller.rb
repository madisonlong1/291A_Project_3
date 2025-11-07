class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: [:show]

  def index
    @conversations = @current_user.initiated_conversations.or(@current_user.assigned_conversations).order(created_at: :desc)
    render json: @conversations.map { |c| conversation_json(c) }, status: :ok
  end

  def show
    if @conversation
      # Verify user is part of this conversation
      unless @conversation.initiator_id == @current_user.id || @conversation.assigned_expert_id == @current_user.id
        return render json: { error: 'Not found' }, status: :not_found
      end
      render json: conversation_json(@conversation), status: :ok
    else
      render json: { error: 'Conversation not found' }, status: :not_found
    end
  end

  def create
    @conversation = Conversation.new(
      title: params[:title],
      initiator: @current_user,
      status: 'waiting'
    )
    if @conversation.save
      render json: conversation_json(@conversation), status: :created
    else
      render json: { errors: @conversation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    @current_user = nil
    
    if token
      decoded = JwtService.decode(token)
      return render json: { error: 'Unauthorized' }, status: :unauthorized if decoded.nil?
      @current_user = User.find(decoded[:user_id]) rescue nil
    end
    
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end

  def set_conversation
    @conversation = Conversation.find_by(id: params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:title, :status, :initiator_id, :assigned_expert_id)
  end

  def conversation_json(conversation)
    {
      id: conversation.id.to_s,
      title: conversation.title,
      status: conversation.status,
      questionerId: conversation.initiator_id.to_s,
      questionerUsername: conversation.initiator&.username,
      assignedExpertId: conversation.assigned_expert_id&.to_s,
      assignedExpertUsername: conversation.assigned_expert&.username,
      createdAt: conversation.created_at&.iso8601,
      updatedAt: conversation.updated_at&.iso8601,
      lastMessageAt: conversation.last_message_at&.iso8601,
      unreadCount: conversation.messages.where('read_at IS NULL AND sender_id != ?', @current_user.id).count
    }
  end
end
