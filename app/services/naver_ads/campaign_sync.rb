module NaverAds
  class CampaignSync
    def self.call(nad_account)
      new(nad_account).call
    end

    def initialize(nad_account)
      @account = nad_account
      @client = Client.new(nad_account)
    end

    def call
      campaigns_data = @client.campaigns
      upsert_campaigns(Array.wrap(campaigns_data))
      sync_ad_groups
    rescue Client::ApiError => e
      Rails.logger.error "[NaverAds::CampaignSync] #{e.message}"
      raise
    end

    private

    def upsert_campaigns(campaigns_data)
      campaigns_data.each do |data|
        campaign = @account.nad_campaigns.find_or_initialize_by(external_id: data["nccCampaignId"])
        campaign.assign_attributes(
          name: data["name"],
          campaign_type: data["campaignTp"],
          status: data["status"],
          budget: data["dailyBudget"],
          synced_at: Time.current
        )
        campaign.save!
      end
    end

    def sync_ad_groups
      @account.nad_campaigns.find_each do |campaign|
        NaverAds::AdGroupSync.call(campaign, @client)
      end
    end
  end
end
