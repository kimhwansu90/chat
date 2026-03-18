module Admin
  class LeadActivitiesController < BaseController
    def create
      @lead = Lead.find(params[:lead_id])
      @activity = @lead.activities.new(activity_params)
      @activity.user = current_user_record

      if @activity.save
        redirect_to admin_lead_path(@lead), notice: "메모가 추가되었습니다."
      else
        redirect_to admin_lead_path(@lead), alert: "메모 추가에 실패했습니다."
      end
    end

    private

    def activity_params
      params.require(:lead_activity).permit(:activity_type, :content)
    end
  end
end
