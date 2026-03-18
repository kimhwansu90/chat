module Admin
  class NadAccountsController < BaseController
    before_action :require_manager
    before_action :set_nad_account, only: %i[show edit update destroy sync]

    def index
      @nad_accounts = NadAccount.order(:name)
    end

    def show
      @campaigns = @nad_account.nad_campaigns.order(:name)
    end

    def new
      @nad_account = NadAccount.new
    end

    def create
      @nad_account = NadAccount.new(nad_account_params)
      if @nad_account.save
        redirect_to admin_nad_accounts_path, notice: "광고 계정이 등록되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      params_to_update = nad_account_params
      # 빈 키/시크릿은 기존 값 유지
      params_to_update = params_to_update.except(:api_key) if params_to_update[:api_key].blank?
      params_to_update = params_to_update.except(:api_secret) if params_to_update[:api_secret].blank?

      if @nad_account.update(params_to_update)
        redirect_to admin_nad_accounts_path, notice: "광고 계정이 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @nad_account.destroy
      redirect_to admin_nad_accounts_path, notice: "광고 계정이 삭제되었습니다."
    end

    def sync
      @nad_account.sync!
      redirect_to admin_nad_account_path(@nad_account), notice: "동기화가 완료되었습니다."
    rescue NaverAds::Client::ApiError => e
      redirect_to admin_nad_account_path(@nad_account), alert: "동기화 실패: #{e.message}"
    end

    private

    def set_nad_account
      @nad_account = NadAccount.find(params[:id])
    end

    def nad_account_params
      params.require(:nad_account).permit(:name, :customer_id, :api_key, :api_secret, :active)
    end
  end
end
