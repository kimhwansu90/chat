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
      period = @date_from.beginning_of_day..@date_to.end_of_day

      # 기간 내 전체 리드 및 계약 현황
      leads_in_period = Lead.where(created_at: period)
      @total_leads    = leads_in_period.count
      @total_converted = leads_in_period.where(status: "converted").count
      @total_revenue  = leads_in_period.where(status: "converted").sum(:contract_value).to_i

      # 네이버 광고비 합계 (기간 내 nad_reports)
      @total_ad_spend = NadReport.where(report_date: @date_from..@date_to).sum(:cost).to_i

      # 순이익 = 매출 - 광고비
      @net_profit = @total_revenue - @total_ad_spend

      # ROI %
      @roi_percent = if @total_ad_spend > 0
        ((@total_revenue.to_f / @total_ad_spend - 1) * 100).round(1)
      else
        0
      end

      # 캠페인별 ROI 분석 (UTM 캠페인 기준)
      @by_campaign = leads_in_period
        .where(status: "converted")
        .where.not(utm_campaign: [nil, ""])
        .group(:utm_campaign)
        .sum(:contract_value)
        .sort_by { |_, v| -v }
        .map do |campaign_name, revenue|
          lead_count = leads_in_period.where(utm_campaign: campaign_name).count
          converted  = leads_in_period.where(status: "converted", utm_campaign: campaign_name).count
          # 해당 캠페인명과 매칭되는 NAD 광고비 (캠페인명 부분 일치)
          ad_spend = NadReport.joins("JOIN nad_campaigns ON nad_reports.entity_id = nad_campaigns.external_id")
                              .where("nad_campaigns.name ILIKE ?", "%#{campaign_name}%")
                              .where(report_date: @date_from..@date_to)
                              .sum(:cost).to_i
          {
            name: campaign_name,
            leads: lead_count,
            converted: converted,
            revenue: revenue.to_i,
            ad_spend: ad_spend,
            net_profit: revenue.to_i - ad_spend,
            conversion_rate: lead_count > 0 ? (converted.to_f / lead_count * 100).round(1) : 0
          }
        end

      # 채널별 매출
      @by_source = leads_in_period
        .where(status: "converted")
        .where.not(utm_source: [nil, ""])
        .group(:utm_source)
        .sum(:contract_value)
        .sort_by { |_, v| -v }

      # 최근 계약 리드
      @recent_contracts = Lead.where(status: "converted")
                              .where("contract_value > 0")
                              .where(created_at: period)
                              .includes(:assigned_to)
                              .order(contracted_at: :desc)
                              .limit(20)
    end

    private

    def set_date_range
      @date_from = params[:date_from].present? ? Date.parse(params[:date_from]) : 30.days.ago.to_date
      @date_to   = params[:date_to].present?   ? Date.parse(params[:date_to])   : Date.today
    end
  end
end
