class ApplicationController < ActionController::Base
  # 최신 브라우저만 허용 (webp, web push 등 지원)
  allow_browser versions: :modern

  # importmap 변경 시 etag 무효화
  stale_when_importmap_changes
  
  # 헬퍼 메서드를 뷰에서도 사용할 수 있도록 설정
  helper_method :current_user, :logged_in?
  
  private
  
  # 현재 로그인한 사용자 이름을 반환
  def current_user
    session[:username]
  end
  
  # 로그인 여부를 확인
  def logged_in?
    current_user.present?
  end
  
  # 로그인하지 않은 경우 로그인 페이지로 리다이렉트
  def require_login
    unless logged_in?
      redirect_to login_path, alert: "로그인이 필요합니다."
    end
  end
end
