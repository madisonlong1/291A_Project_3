class MessagesController < ApplicationController
  before_action :set_message, only: [:mark_read]
  def index
    @messages = Message.where(conversation_id: params[:conversation_id])
    render json:@messages
  end

  def create
    @message = Message.new(message_params)
    if @message.save
      render json: @message,status: :created
    else
      render json:{errors:@message.errors.full_messages},status: :unprocessable_entity
    end
  end

  def mark_read
    if @message.update(is_read:true)
      render json:{success:true},status: :ok
    else
      render json:{error:"Unable to mark message as read"},status: :unprocessable_entity
    end
  end


  private
  def set_message
    @message = Message.find_by(id: params[:id])
  end

  def message_params
    params.require(:message).permit(:conversation_id, :sender_id, :sender_role, :content)
  end

end
