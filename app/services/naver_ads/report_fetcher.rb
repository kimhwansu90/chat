module NaverAds
  class ReportFetcher
    def self.call(nad_account, date_from:, date_to:)
      new(nad_account, date_from: date_from, date_to: date_to).call
    end

    def initialize(nad_account, date_from:, date_to:)
      @account = nad_account
      @date_from = date_from
      @date_to = date_to
      @client = Client.new(nad_account)
    end

    def call
      fetch_campaign_reports
    rescue Client::ApiError => e
      Rails.logger.error "[NaverAds::ReportFetcher] account=#{@account.id} #{e.message}"
      raise
    end

    private

    def fetch_campaign_reports
      @account.nad_campaigns.find_each do |campaign|
        data = @client.report(
          report_type: "campaign",
          date_from: @date_from,
          date_to: @date_to,
          id: campaign.external_id
        )

        Array.wrap(data).each do |row|
          report_date = Date.parse(row["dt"] || row["date"])
          upsert_report(campaign.external_id, "campaign", report_date, row)
        end
      end
    end

    def upsert_report(entity_id, report_type, report_date, data)
      NadReport.find_or_initialize_by(
        nad_account: @account,
        report_type: report_type,
        entity_id: entity_id.to_s,
        report_date: report_date
      ).update!(
        impressions: data["impCnt"] || data["impressions"] || 0,
        clicks: data["clkCnt"] || data["clicks"] || 0,
        conversions: data["salesCnt"] || data["conversions"] || 0,
        cost: data["salesAmt"] || data["cost"] || 0,
        revenue: data["rvsCnt"] || data["revenue"] || 0
      )
    end
  end
end
