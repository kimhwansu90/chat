class ChatChannel < ApplicationCable::Channel
  @@online_users = Set.new

  def subscribed
    stream_from "chat_channel"
    @@online_users.add(current_user)
    broadcast_online_status
  end

  def unsubscribed
    @@online_users.delete(current_user)
    broadcast_online_status
  end

  def self.online_users
    @@online_users
  end

  private

  def broadcast_online_status
    ActionCable.server.broadcast("admin_channel", {
      type: "online_users",
      users: @@online_users.to_a,
      count: @@online_users.size
    })
  end
end
