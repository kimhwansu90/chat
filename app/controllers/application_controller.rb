class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user_record, :current_user, :current_nickname, :logged_in?

  private

  def current_user_record
    @current_user_record ||= User.find_by(id: session[:user_id])
  end

  def current_user
    current_user_record&.username
  end

  def current_nickname
    current_user_record&.nickname
  end

  def logged_in?
    current_user_record.present?
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "로그인이 필요합니다."
    end
  end
end
