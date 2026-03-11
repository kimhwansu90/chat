class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  helper_method :current_user_record, :current_user, :current_nickname, :logged_in?
  before_action :update_last_seen

  private

  def update_last_seen
    return unless logged_in?
    return if current_user_record.admin?
    return if current_user_record.last_seen_at && current_user_record.last_seen_at > 5.minutes.ago

    current_user_record.touch_last_seen!
  end

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
