module Admin
  class LeadsController < BaseController
    before_action :set_lead, only: [:show, :edit, :update, :destroy, :update_status, :assign, :update_contract]

    def index
      @leads_by_status = Lead::STATUSES.each_with_object({}) do |status, hash|
        hash[status] = Lead.includes(:assigned_to, :form)
                           .by_status(status)
                           .recent
      end
      @sales_reps = User.sales_reps.active
    end

    def show
      @activities = @lead.activities.includes(:user).recent
      @sales_reps = User.sales_reps.active
    end

    def new
      @lead = Lead.new
      @sales_reps = User.sales_reps.active
      @forms = Form.active
    end

    def create
      @lead = Lead.new(lead_params)

      if @lead.save
        @lead.activities.create!(
          activity_type: "note",
          user: current_user_record,
          content: "수동으로 리드 등록"
        )
        redirect_to admin_lead_path(@lead), notice: "리드가 등록되었습니다."
      else
        @sales_reps = User.sales_reps.active
        @forms = Form.active
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @sales_reps = User.sales_reps.active
      @forms = Form.active
    end

    def update
      if @lead.update(lead_params)
        redirect_to admin_lead_path(@lead), notice: "리드가 수정되었습니다."
      else
        @sales_reps = User.sales_reps.active
        @forms = Form.active
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @lead.destroy
      redirect_to admin_leads_path, notice: "리드가 삭제되었습니다."
    end

    def update_status
      new_status = params[:status]
      if Lead::STATUSES.include?(new_status)
        @lead.change_status!(new_status, user: current_user_record)
        head :ok
      else
        head :unprocessable_entity
      end
    end

    def assign
      sales_rep = User.find(params[:sales_rep_id])
      @lead.assign_to!(sales_rep, assigned_by: current_user_record)
      redirect_to admin_lead_path(@lead), notice: "#{sales_rep.nickname}에게 배정되었습니다."
    end

    def update_contract
      value = params[:contract_value].to_s.gsub(/[^0-9]/, "").to_i
      @lead.update!(contract_value: value, contracted_at: @lead.contracted_at || Time.current)
      @lead.activities.create!(
        activity_type: "note",
        user: current_user_record,
        content: "계약금액 #{number_with_delimiter(value)}원 입력"
      )
      redirect_to admin_lead_path(@lead), notice: "계약금액이 저장되었습니다."
    end

    private

    def set_lead
      @lead = Lead.find(params[:id])
    end

    def lead_params
      params.require(:lead).permit(:name, :phone, :email, :status, :form_id, :assigned_to_id,
                                   :utm_source, :utm_medium, :utm_campaign, :contract_value)
    end
  end
end
