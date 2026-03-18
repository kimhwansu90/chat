class LeadNotificationChannel < ApplicationCable::Channel
  def subscribed
    stream_from "lead_notifications_user_#{current_user.id}"

    if current_user.manager_or_above?
      stream_from "lead_notifications_global"
    end
  end
end
