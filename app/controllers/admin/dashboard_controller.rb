module Admin
  class DashboardController < BaseController
    def index
      @stats = LeadStatsQuery.new.call(date_from: 30.days.ago.to_date, date_to: Date.today)
      @recent_leads = Lead.includes(:assigned_to, :form).recent.limit(10)
      @sales_rep_stats = @stats[:by_sales_rep].first(5)
    end
  end
end
