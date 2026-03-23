module Admin
  class FormsController < BaseController
    before_action :set_form, only: [:show, :edit, :update, :destroy, :preview, :toggle_active]

    def index
      @forms = Form.includes(:created_by).order(created_at: :desc)
    end

    def show
      @leads_count = @form.leads.count
    end

    def new
      @form = Form.new(
        privacy_policy_text: default_privacy_policy,
        submit_button_text: "상담문의",
        thank_you_message: "문의가 접수되었습니다. 빠르게 연락 드리겠습니다."
      )
      build_default_fields(@form)
    end

    def create
      @form = Form.new(form_params)
      @form.created_by = current_user_record

      if @form.save
        redirect_to admin_form_path(@form), notice: "폼이 생성되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @form.update(form_params)
        redirect_to admin_form_path(@form), notice: "폼이 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @form.destroy
      redirect_to admin_forms_path, notice: "폼이 삭제되었습니다."
    end

    def preview
      @form_fields = @form.form_fields
    end

    def toggle_active
      @form.update!(active: !@form.active)
      status = @form.active? ? "활성화" : "비활성화"
      redirect_to admin_forms_path, notice: "폼이 #{status}되었습니다."
    end

    private

    def set_form
      @form = Form.find(params[:id])
    end

    def form_params
      params.require(:form).permit(
        :name, :description, :redirect_url, :thank_you_message,
        :privacy_policy_text, :submit_button_text,
        form_fields_attributes: [
          :id, :label, :field_type, :name, :required, :options,
          :placeholder, :half_width, :subtitle, :position, :_destroy
        ]
      )
    end

    def build_default_fields(form)
      default_fields = [
        { label: "상호명 (회사명)", field_type: "text", name: "company_name", required: true, half_width: true, position: 0 },
        { label: "담당자명", field_type: "text", name: "name", required: true, half_width: true, position: 1 },
        { label: "연락처", field_type: "phone", name: "phone", required: true, half_width: true, position: 2 },
        { label: "이메일", field_type: "email", name: "email", required: true, half_width: true, position: 3 },
        { label: "상담 가능 시간", field_type: "text", name: "available_time", required: false, half_width: true, placeholder: "예: 오후 2시~5시", position: 4 },
        { label: "주소", field_type: "text", name: "address", required: false, half_width: true, position: 5 },
        { label: "관심 서비스", field_type: "button_select", name: "service_interest", required: true, options: "플레이스 상위노출,체험단 마케팅,쇼핑 상위노출,블로그 마케팅,SNS 광고,기타", position: 6 },
        { label: "월 광고 예산", field_type: "button_select", name: "monthly_budget", required: true, options: "30~100만원,100~200만원,200~500만원,500만원 이상", position: 7 },
        { label: "현재 마케팅 이력", field_type: "textarea", name: "marketing_history", required: false, placeholder: "예: 네이버 파워링크 월 300만원 집행 중", position: 8 },
        { label: "업체 소개 및 요청사항", field_type: "textarea", name: "company_info", required: false, placeholder: "주력 분야, 업체 특징, 원하시는 마케팅 방향 등", position: 9 }
      ]

      default_fields.each { |attrs| form.form_fields.build(attrs) }
    end

    def default_privacy_policy
      <<~POLICY.strip
        1. 수집하는 개인정보 항목
        - 필수항목: 상호명(회사명), 담당자명, 연락처, 이메일
        - 선택항목: 주소, 상담 가능 시간, 관심 서비스, 월 광고 예산, 마케팅 이력, 업체 정보

        2. 개인정보의 수집 및 이용 목적
        - 광고/마케팅 상담 및 견적 제공
        - 서비스 안내 및 계약 체결
        - 상담 이력 관리 및 고객 문의 응대

        3. 개인정보의 보유 및 이용 기간
        - 수집일로부터 1년간 보유하며, 이용 목적 달성 후 즉시 파기합니다.
        - 관계 법령에 의해 보존이 필요한 경우 해당 기간 동안 보관합니다.

        4. 개인정보의 제3자 제공
        - 수집된 개인정보는 원칙적으로 제3자에게 제공하지 않습니다.
        - 다만, 법률에 의거하여 요구되는 경우에는 예외로 합니다.

        5. 동의 거부권 및 불이익
        - 개인정보 수집 및 이용에 대한 동의를 거부할 수 있으며, 거부 시 상담 신청이 제한될 수 있습니다.
      POLICY
    end
  end
end
