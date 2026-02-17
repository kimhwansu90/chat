module Admin
  class ReportsController < BaseController
    skip_before_action :verify_authenticity_token, only: [:review, :dismiss]

    def index
      @reports = Report.includes(:message).order(created_at: :desc)
    end

    def review
      report = Report.find(params[:id])
      report.update(status: "reviewed", reviewed_by: current_user)
      redirect_to admin_reports_path, notice: "신고가 처리되었습니다."
    end

    def dismiss
      report = Report.find(params[:id])
      report.update(status: "dismissed", reviewed_by: current_user)
      redirect_to admin_reports_path, notice: "신고가 기각되었습니다."
    end
  end
end
