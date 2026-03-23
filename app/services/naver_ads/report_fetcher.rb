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
      fetch_adgroup_reports
    rescue Client::ApiError => e
      Rails.logger.error "[NaverAds::ReportFetcher] account=#{@account.id} #{e.message}"
      raise
    end

    private

    def fetch_campaign_reports
      data = @client.stats(
        stat_type: "CAMP",
        date_from: @date_from,
        date_to: @date_to
      )

      Array.wrap(data).each do |row|
        next if row["id"].blank?
        report_date = parse_date(row["dt"] || row["date"])
        next unless report_date

        upsert_report(row["id"].to_s, "campaign", report_date, row)
      end
    end

    def fetch_adgroup_reports
      data = @client.stats(
        stat_type: "ADGRP",
        date_from: @date_from,
        date_to: @date_to
      )

      Array.wrap(data).each do |row|
        next if row["id"].blank?
        report_date = parse_date(row["dt"] || row["date"])
        next unless report_date

        upsert_report(row["id"].to_s, "ad_group", report_date, row)
      end
    end

    def parse_date(value)
      return nil if value.blank?
      raw = value.to_s.gsub("-", "")
      Date.strptime(raw, "%Y%m%d")
    rescue Date::Error
      nil
    end

    def upsert_report(entity_id, report_type, report_date, data)
      NadReport.find_or_initialize_by(
        nad_account: @account,
        report_type: report_type,
        entity_id: entity_id,
        report_date: report_date
      ).update!(
        impressions: data["impCnt"].to_i,
        clicks: data["clkCnt"].to_i,
        conversions: data["ccnt"].to_i,
        cost: data["salesAmt"].to_i,
        revenue: data["convAmt"].to_i
      )
    end
  end
end
