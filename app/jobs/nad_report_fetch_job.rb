# 네이버 검색광고 성과 리포트 자동 수집 잡
# 매일 새벽 4시 실행, 전날 데이터를 가져옴 (recurring.yml)
class NadReportFetchJob < ApplicationJob
  queue_as :default

  retry_on NaverAds::Client::ApiError, wait: 10.minutes, attempts: 3

  def perform(nad_account_id = nil, days_back: 1)
    date_from = days_back.days.ago.to_date
    date_to = Date.yesterday

    accounts = nad_account_id ? [NadAccount.find(nad_account_id)] : NadAccount.active.to_a
    accounts.each do |account|
      Rails.logger.info "[NadReportFetchJob] fetching account=#{account.id} #{date_from}~#{date_to}"
      NaverAds::ReportFetcher.call(account, date_from: date_from, date_to: date_to)
    end
  end
end
