class ConversationChannel < ApplicationCable::Channel
  def subscribed
    conversation = Conversation.find_by(id: params[:conversation_id])

    if conversation && authorized?(conversation)
      stream_from conversation.channel_name
    else
      reject
    end
  end

  def unsubscribed
  end

  private

  def authorized?(conversation)
    current_user.admin? || conversation.user_id == current_user.id
  end
end
