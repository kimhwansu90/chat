module Admin
  class DashboardController < BaseController
    def index
      @total_users = User.where.not(role: "admin").count
      @today_messages = Message.where("created_at >= ?", Time.current.beginning_of_day).count
      @conversations = Conversation.includes(:user).order(last_message_at: :desc)
      @nicknames = User.pluck(:username, :nickname).to_h
    end
  end
end
