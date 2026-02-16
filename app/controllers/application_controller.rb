class ApplicationController < ActionController::Base
  # 최신 브라우저만 허용 (webp, web push 등 지원)
  allow_browser versions: :modern

  # importmap 변경 시 etag 무효화
  stale_when_importmap_changes
  
  # 헬퍼 메서드를 뷰에서도 사용할 수 있도록 설정
  helper_method :current_user, :current_nickname, :logged_in?, :nickname_set?
  
  private
  
  # 현재 로그인한 사용자 이름을 반환 (admin, user 등)
  def current_user
    session[:username]
  end
  
  # 현재 사용자의 닉네임을 반환 (한글 가능)
  def current_nickname
    session[:nickname]
  end
  
  # 로그인 여부를 확인
  def logged_in?
    current_user.present?
  end
  
  # 닉네임 설정 여부를 확인
  def nickname_set?
    current_nickname.present?
  end
  
  # 로그인하지 않은 경우 로그인 페이지로 리다이렉트
  def require_login
    unless logged_in?
      redirect_to login_path, alert: "로그인이 필요합니다."
    end
  end
  
  # 닉네임이 없는 경우 DB에서 로드하여 세션에 설정
  def require_nickname
    if logged_in? && !nickname_set?
      user = User.find_by(username: current_user)
      if user&.nickname.present?
        session[:nickname] = user.nickname
      else
        # DB에도 없으면 기본 닉네임 설정
        default_nickname = SessionsController::USERS.dig(current_user, :nickname) || current_user
        user&.update(nickname: default_nickname) if user
        session[:nickname] = default_nickname
      end
    end
  end
end
