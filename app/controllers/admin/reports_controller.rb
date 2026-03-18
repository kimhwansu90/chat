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

    def roi_report
      ad_spends_in_period = AdSpend.in_period(@date_from, @date_to)

      # 채널별 지출/매출 (AdSpend 직접 입력 기준)
      @channel_stats = ad_spends_in_period.group(:channel).sum(:amount).map do |channel, spend|
        revenue = ad_spends_in_period.where(channel: channel).sum(:revenue).to_i
        { channel: channel, spend: spend.to_i, revenue: revenue, net: revenue - spend.to_i }
      end.sort_by { |s| -s[:spend] }

      @total_ad_spend = @channel_stats.sum { |s| s[:spend] }
      @total_revenue  = @channel_stats.sum { |s| s[:revenue] }
      @net_profit     = @total_revenue - @total_ad_spend
      @roi_percent    = if @total_ad_spend > 0
        ((@total_revenue.to_f / @total_ad_spend - 1) * 100).round(1)
      else
        0
      end

      # 팀별 성과 (계약 완료 기준, contracted_at 기준)
      contract_period = @date_from.beginning_of_day..@date_to.end_of_day
      converted_leads = Lead.where(status: "converted")
                            .where(contracted_at: contract_period)
                            .where("contract_value > 0")
                            .includes(:assigned_to)

      @team_stats = converted_leads.group_by { |l| l.assigned_to }.map do |rep, leads|
        { rep: rep, count: leads.size, revenue: leads.sum { |l| l.contract_value.to_i } }
      end.sort_by { |s| -s[:revenue] }

      @total_converted = converted_leads.count

      # 광고비 상세 내역
      @ad_spends = ad_spends_in_period.order(:channel, :period_start)

      # 최근 계약 리드
      @recent_contracts = converted_leads.order(contracted_at: :desc).limit(20)
    end

    private

    def set_date_range
      @date_from = params[:date_from].present? ? Date.parse(params[:date_from]) : 30.days.ago.to_date
      @date_to   = params[:date_to].present?   ? Date.parse(params[:date_to])   : Date.today
    end
  end
end
