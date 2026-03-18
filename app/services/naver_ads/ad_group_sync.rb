module NaverAds
  class AdGroupSync
    def self.call(campaign, client = nil)
      new(campaign, client).call
    end

    def initialize(campaign, client = nil)
      @campaign = campaign
      @client = client || Client.new(campaign.nad_account)
    end

    def call
      ad_groups_data = @client.ad_groups(campaign_id: @campaign.external_id)
      upsert_ad_groups(Array.wrap(ad_groups_data))
    rescue Client::ApiError => e
      Rails.logger.error "[NaverAds::AdGroupSync] campaign=#{@campaign.external_id} #{e.message}"
      raise
    end

    private

    def upsert_ad_groups(ad_groups_data)
      ad_groups_data.each do |data|
        ad_group = @campaign.nad_ad_groups.find_or_initialize_by(external_id: data["nccAdgroupId"])
        ad_group.assign_attributes(
          name: data["name"],
          status: data["status"],
          synced_at: Time.current
        )
        ad_group.save!
      end
    end
  end
end
