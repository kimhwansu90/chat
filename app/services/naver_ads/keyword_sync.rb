module NaverAds
  class KeywordSync
    def self.call(ad_group, client = nil)
      new(ad_group, client).call
    end

    def initialize(ad_group, client = nil)
      @ad_group = ad_group
      @client = client || Client.new(ad_group.nad_campaign.nad_account)
    end

    def call
      keywords_data = @client.keywords(ad_group_id: @ad_group.external_id)
      upsert_keywords(Array.wrap(keywords_data))
    rescue Client::ApiError => e
      Rails.logger.error "[NaverAds::KeywordSync] ad_group=#{@ad_group.external_id} #{e.message}"
      raise
    end

    private

    def upsert_keywords(keywords_data)
      keywords_data.each do |data|
        keyword = @ad_group.nad_keywords.find_or_initialize_by(external_id: data["nccKeywordId"])
        keyword.assign_attributes(
          keyword: data["keyword"],
          match_type: data["matchTp"],
          status: data["status"],
          bid_amount: data["bidAmt"],
          synced_at: Time.current
        )
        keyword.save!
      end
    end
  end
end
