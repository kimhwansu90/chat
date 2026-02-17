module Admin
  class DashboardController < BaseController
    def index
      @total_users = User.count
      @today_messages = Message.where("created_at >= ?", Time.current.beginning_of_day).count
      @online_users = ChatChannel.online_users.to_a
      @pending_reports = Report.pending.count
      @recent_messages = Message.order(created_at: :desc).limit(20)
      @nicknames = User.pluck(:username, :nickname).to_h
    end
  end
end
