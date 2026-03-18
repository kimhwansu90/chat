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
      @form = Form.new
      @form.form_fields.build
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
      params.require(:form).permit(:name, :slug, :description, :redirect_url, :thank_you_message,
        form_fields_attributes: [:id, :label, :field_type, :name, :required, :options, :position, :_destroy])
    end
  end
end
