module Admin
  class NadReportsController < BaseController
    before_action :require_manager

    def index
      @nad_accounts = NadAccount.active.order(:name)
      @selected_account = params[:nad_account_id].present? ? NadAccount.find(params[:nad_account_id]) : @nad_accounts.first

      @date_from = params[:date_from].present? ? Date.parse(params[:date_from]) : 30.days.ago.to_date
      @date_to = params[:date_to].present? ? Date.parse(params[:date_to]) : Date.today

      if @selected_account
        @reports = @selected_account.nad_reports
          .campaigns
          .for_date_range(@date_from, @date_to)
          .by_date

        @totals = {
          impressions: @reports.sum(:impressions),
          clicks: @reports.sum(:clicks),
          conversions: @reports.sum(:conversions),
          cost: @reports.sum(:cost)
        }

        @daily_data = @reports.group(:report_date).sum(:cost).sort.map do |date, cost|
          { date: date.strftime("%m/%d"), cost: cost }
        end
      end
    end

    def fetch
      nad_account = NadAccount.find(params[:nad_account_id])
      date_from = Date.parse(params[:date_from])
      date_to = Date.parse(params[:date_to])

      NaverAds::ReportFetcher.call(nad_account, date_from: date_from, date_to: date_to)
      redirect_to admin_nad_reports_path(nad_account_id: nad_account.id), notice: "리포트 데이터를 가져왔습니다."
    rescue NaverAds::Client::ApiError => e
      redirect_to admin_nad_reports_path, alert: "데이터 조회 실패: #{e.message}"
    end
  end
end
