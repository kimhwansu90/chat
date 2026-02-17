module Admin
  class BaseController < ApplicationController
    before_action :require_login
    before_action :require_admin
    layout "admin"

    private

    def require_admin
      unless current_user == "admin"
        redirect_to chat_path, alert: "관리자만 접근 가능합니다."
      end
    end
  end
end
