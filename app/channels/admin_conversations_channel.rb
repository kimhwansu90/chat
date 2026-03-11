class AdminConversationsChannel < ApplicationCable::Channel
  def subscribed
    if current_user.admin?
      stream_from "admin_conversations"
    else
      reject
    end
  end

  def unsubscribed
  end
end
