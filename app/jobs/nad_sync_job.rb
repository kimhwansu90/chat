# 네이버 검색광고 캠페인/광고그룹/키워드 자동 동기화 잡
# 매일 새벽 3시 실행 (recurring.yml)
class NadSyncJob < ApplicationJob
  queue_as :default

  retry_on NaverAds::Client::ApiError, wait: 5.minutes, attempts: 3

  def perform(nad_account_id = nil)
    accounts = nad_account_id ? [NadAccount.find(nad_account_id)] : NadAccount.active.to_a
    accounts.each do |account|
      Rails.logger.info "[NadSyncJob] syncing account=#{account.id} (#{account.name})"
      account.sync!
    end
  end
end
