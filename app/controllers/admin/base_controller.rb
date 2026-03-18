module Admin
  class BaseController < ApplicationController
    before_action :require_login
    before_action :require_staff
    layout "admin"

    private

    def require_staff
      unless current_user_record&.role&.in?(%w[admin manager sales_rep])
        redirect_to login_path, alert: "접근 권한이 없습니다."
      end
    end

    def require_manager
      unless current_user_record&.manager_or_above?
        redirect_to admin_root_path, alert: "매니저 이상만 접근 가능합니다."
      end
    end

    def require_admin
      unless current_user_record&.admin?
        redirect_to admin_root_path, alert: "관리자만 접근 가능합니다."
      end
    end
  end
end
