module Admin
  class NadCampaignsController < BaseController
    before_action :require_manager

    def index
      @nad_accounts = NadAccount.active.order(:name)
      @selected_account = params[:nad_account_id].present? ? NadAccount.find(params[:nad_account_id]) : @nad_accounts.first
      @campaigns = @selected_account ? @selected_account.nad_campaigns.order(:name) : NadCampaign.none
    end

    def show
      @campaign = NadCampaign.find(params[:id])
      @ad_groups = @campaign.nad_ad_groups.order(:name)
    end
  end
end
