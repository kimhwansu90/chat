module Admin
  class AdSpendsController < BaseController
    before_action :require_manager
    before_action :set_ad_spend, only: [:edit, :update, :destroy]

    def index
      @ad_spends = AdSpend.includes(:created_by).recent
      @total_by_channel = AdSpend.group(:channel).sum(:amount)
    end

    def new
      @ad_spend = AdSpend.new(
        period_start: Date.today.beginning_of_month,
        period_end: Date.today
      )
    end

    def create
      @ad_spend = AdSpend.new(ad_spend_params)
      @ad_spend.created_by = current_user_record

      if @ad_spend.save
        redirect_to admin_ad_spends_path, notice: "광고비가 등록되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @ad_spend.update(ad_spend_params)
        redirect_to admin_ad_spends_path, notice: "광고비가 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @ad_spend.destroy
      redirect_to admin_ad_spends_path, notice: "삭제되었습니다."
    end

    private

    def set_ad_spend
      @ad_spend = AdSpend.find(params[:id])
    end

    def ad_spend_params
      params.require(:ad_spend).permit(
        :channel, :campaign_name, :amount, :period_start, :period_end, :memo
      )
    end
  end
end
