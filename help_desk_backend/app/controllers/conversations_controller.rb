class ConversationsController < ApplicationController
  before_action :set_conversation, only: [:show]
  def index
    @conversations = Conversation.all
    render json:@conversations
  end

  def show
    if @conversation
      render json:@conversation
    else
      render json:{error:"Conversation not found"},status: :not_found
    end
  end

  def create
    @conversation = Conversation.new(conversation_params)
    if @conversation.save
      render json:@conversation, status: :created
    else
      render json:{errors:@conversation.errors.full_messages}, status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find_by(id: params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:title, :status, :initiator_id, :assigned_expert_id)
  end

end
