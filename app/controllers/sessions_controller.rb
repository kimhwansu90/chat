class SessionsController < ApplicationController
  # 허용된 사용자 계정 (하드코딩)
  # 실제 운영 시 데이터베이스나 환경 변수로 관리하는 것이 좋습니다
  USERS = {
    "admin" => { password: "7359", nickname: "관리자" },
    "user" => { password: "1234", nickname: "유타지" }
  }.freeze

  # 로그인 페이지 표시
  def new
    # 이미 로그인한 경우 채팅 페이지로 리다이렉트
    redirect_to chat_path if logged_in?
  end

  # 로그인 처리
  def create
    username = params[:username]
    password = params[:password]

    user_info = USERS[username]

    # 사용자 인증 확인
    if user_info && user_info[:password] == password
      # DB에서 유저 찾거나 생성
      user = User.find_or_create_by(username: username)

      # DB에 닉네임이 없으면 기본 닉네임 저장
      if user.nickname.blank?
        user.update(nickname: user_info[:nickname])
      end

      # 세션에 사용자 이름과 닉네임 저장
      session[:username] = username
      session[:nickname] = user.nickname

      redirect_to chat_path, notice: "#{user.nickname}님, 환영합니다!"
    else
      # 로그인 실패: 에러 메시지와 함께 로그인 페이지로
      flash.now[:alert] = "아이디 또는 비밀번호가 올바르지 않습니다."
      render :new, status: :unprocessable_entity
    end
  end

  # 닉네임 입력 폼 (옵션: 사용자가 원하면 닉네임 변경 가능)
  def nickname_form
    # 로그인하지 않은 경우 로그인 페이지로
    redirect_to login_path unless logged_in?
  end

  # 닉네임 변경 (선택사항)
  def set_nickname
    nickname = params[:nickname]&.strip

    if nickname.present?
      # 세션과 DB 모두에 닉네임 저장
      session[:nickname] = nickname
      user = User.find_by(username: current_user)
      user&.update(nickname: nickname)

      redirect_to chat_path, notice: "닉네임이 '#{nickname}'(으)로 변경되었습니다!"
    else
      flash.now[:alert] = "닉네임을 입력해주세요."
      render :nickname_form, status: :unprocessable_entity
    end
  end

  # 로그아웃 처리
  def destroy
    # 세션만 삭제 (DB 닉네임은 유지)
    session.delete(:username)
    session.delete(:nickname)
    redirect_to login_path, notice: "로그아웃되었습니다."
  end
end
