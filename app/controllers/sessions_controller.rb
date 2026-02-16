class SessionsController < ApplicationController
  # 허용된 사용자 계정 (하드코딩)
  # 실제 운영 시 데이터베이스나 환경 변수로 관리하는 것이 좋습니다
  USERS = {
    "관리자" => "7359",
    "유타지" => "1234"
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
    
    # 사용자 인증 확인
    if USERS[username] == password
      # 로그인 성공: 세션에 사용자 이름 저장
      session[:username] = username
      redirect_to chat_path, notice: "#{username}님, 환영합니다!"
    else
      # 로그인 실패: 에러 메시지와 함께 로그인 페이지로
      flash.now[:alert] = "아이디 또는 비밀번호가 올바르지 않습니다."
      render :new, status: :unprocessable_entity
    end
  end

  # 로그아웃 처리
  def destroy
    # 세션에서 사용자 정보 삭제
    session.delete(:username)
    redirect_to login_path, notice: "로그아웃되었습니다."
  end
end
