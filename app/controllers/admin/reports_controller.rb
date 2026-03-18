module Admin
  class ReportsController < BaseController
    before_action :require_manager
    before_action :set_date_range

    def index
      @stats = LeadStatsQuery.new.call(date_from: @date_from, date_to: @date_to)
    end

    def lead_report
      @stats = LeadStatsQuery.new.call(date_from: @date_from, date_to: @date_to)
      @leads = Lead.where(created_at: @date_from.beginning_of_day..@date_to.end_of_day)
                   .includes(:assigned_to, :form)
                   .order(created_at: :desc)
                   .limit(200)
    end

    def channel_report
      @stats = LeadStatsQuery.new.call(date_from: @date_from, date_to: @date_to)
      @by_channel = @stats[:by_channel]
      @by_campaign = Lead.where(created_at: @date_from.beginning_of_day..@date_to.end_of_day)
                         .where.not(utm_campaign: [nil, ""])
                         .group(:utm_campaign).count.sort_by { |_, v| -v }.first(10)
    end

    def team_report
      @stats = LeadStatsQuery.new.call(date_from: @date_from, date_to: @date_to)
      @by_sales_rep = @stats[:by_sales_rep]
    end

    private

    def set_date_range
      @date_from = params[:date_from].present? ? Date.parse(params[:date_from]) : 30.days.ago.to_date
      @date_to = params[:date_to].present? ? Date.parse(params[:date_to]) : Date.today
    end
  end
end
