class SessionsController < ApplicationController
  # 허용된 사용자 계정 (하드코딩)
  # 실제 운영 시 데이터베이스나 환경 변수로 관리하는 것이 좋습니다
  USERS = {
    "admin" => "7359",      # 관리자
    "user" => "1234"         # 유타지
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
      # 닉네임 설정 페이지로 이동
      redirect_to nickname_path, notice: "닉네임을 입력해주세요."
    else
      # 로그인 실패: 에러 메시지와 함께 로그인 페이지로
      flash.now[:alert] = "아이디 또는 비밀번호가 올바르지 않습니다."
      render :new, status: :unprocessable_entity
    end
  end
  
  # 닉네임 입력 폼
  def nickname_form
    # 로그인하지 않은 경우 로그인 페이지로
    redirect_to login_path unless logged_in?
    # 이미 닉네임이 있으면 채팅으로
    redirect_to chat_path if session[:nickname].present?
  end
  
  # 닉네임 저장
  def set_nickname
    nickname = params[:nickname]&.strip
    
    if nickname.present?
      session[:nickname] = nickname
      redirect_to chat_path, notice: "#{nickname}님, 환영합니다!"
    else
      flash.now[:alert] = "닉네임을 입력해주세요."
      render :nickname_form, status: :unprocessable_entity
    end
  end

  # 로그아웃 처리
  def destroy
    # 세션에서 사용자 정보 및 닉네임 삭제
    session.delete(:username)
    session.delete(:nickname)
    redirect_to login_path, notice: "로그아웃되었습니다."
  end
end
