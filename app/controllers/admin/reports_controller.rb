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
      contract_period = @date_from.beginning_of_day..@date_to.end_of_day

      # 계약 완료 리드 (contracted_at 기준) - 계약금액이 매출
      converted_leads = Lead.where(status: "converted")
                            .where(contracted_at: contract_period)
                            .includes(:assigned_to)

      # 매출 = 리드 계약금액 합산
      @total_revenue  = converted_leads.sum(:contract_value).to_i
      @total_converted = converted_leads.count

      # 광고비 = 수동 입력 AdSpend
      ad_spends_in_period = AdSpend.in_period(@date_from, @date_to)
      @total_ad_spend = ad_spends_in_period.sum(:amount).to_i

      @net_profit  = @total_revenue - @total_ad_spend
      @roi_percent = if @total_ad_spend > 0
        ((@total_revenue.to_f / @total_ad_spend - 1) * 100).round(1)
      else
        0
      end

      # 채널별 광고비 지출
      @channel_stats = ad_spends_in_period.group(:channel).sum(:amount).map do |channel, spend|
        { channel: channel, spend: spend.to_i }
      end.sort_by { |s| -s[:spend] }

      # 팀별 계약 결과
      @team_stats = converted_leads.where("contract_value > 0").group_by(&:assigned_to).map do |rep, leads|
        { rep: rep, count: leads.size, revenue: leads.sum { |l| l.contract_value.to_i } }
      end.sort_by { |s| -s[:revenue] }

      # 광고비 상세 내역
      @ad_spends = ad_spends_in_period.order(:channel, :period_start)

      # 최근 계약 리드
      @recent_contracts = converted_leads.where("contract_value > 0").order(contracted_at: :desc).limit(20)
    end

    private

    def set_date_range
      @date_from = params[:date_from].present? ? Date.parse(params[:date_from]) : 30.days.ago.to_date
      @date_to   = params[:date_to].present?   ? Date.parse(params[:date_to])   : Date.today
    end
  end
end
