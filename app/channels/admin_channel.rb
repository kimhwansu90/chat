class AdminChannel < ApplicationCable::Channel
  def subscribed
    if current_user == "admin"
      stream_from "admin_channel"
    else
      reject
    end
  end

  def unsubscribed
  end
end
