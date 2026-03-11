class ConversationsController < ApplicationController
  before_action :require_login

  def index
    if current_user_record.admin?
      redirect_to admin_root_path
      return
    end

    conversation = current_user_record.conversation_with_admin
    redirect_to conversation_path(conversation)
  end

  def show
    @conversation = find_authorized_conversation
    return redirect_to login_path unless @conversation

    @conversation.reset_unread_for!(current_user_record.role)
    @messages = @conversation.messages.includes(image_attachment: :blob).order(created_at: :asc).last(100)
    @other_user = @conversation.other_participant(current_user)
  end

  def mark_read
    conversation = find_authorized_conversation
    return head :forbidden unless conversation

    conversation.reset_unread_for!(current_user_record.role)

    ActionCable.server.broadcast(conversation.channel_name, {
      type: "read_receipt",
      reader: current_user
    })

    head :ok
  end

  private

  def find_authorized_conversation
    conversation = Conversation.find_by(id: params[:id])
    return nil unless conversation

    if current_user_record.admin? || conversation.user_id == current_user_record.id
      conversation
    end
  end
end
