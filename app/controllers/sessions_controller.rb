class SessionsController < ApplicationController
  def new
    redirect_to admin_root_path if logged_in?
  end

  def create
    user = User.find_by(username: params[:username])

    if user&.authenticate(params[:password])
      if user.banned?
        flash.now[:alert] = "차단된 계정입니다. 사유: #{user.banned_reason || '관리자에 의한 차단'}"
        render :new, status: :unprocessable_entity
        return
      end

      unless user.active?
        flash.now[:alert] = "비활성화된 계정입니다."
        render :new, status: :unprocessable_entity
        return
      end

      session[:user_id] = user.id
      user.touch_last_seen!
      redirect_to admin_root_path, notice: "#{user.nickname}님, 환영합니다!"
    else
      flash.now[:alert] = "아이디 또는 비밀번호가 올바르지 않습니다."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to login_path, notice: "로그아웃되었습니다."
  end
end
