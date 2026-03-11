module Admin
  class UsersController < BaseController
    skip_before_action :verify_authenticity_token, only: [:create, :update_nickname, :ban, :unban, :kick]

    def index
      @users = User.where.not(role: "admin").order(:username)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      @user.role = "user"

      if @user.save
        @user.conversations.create!(last_message_at: Time.current)
        redirect_to admin_users_path, notice: "#{@user.nickname} 계정이 생성되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update_nickname
      user = User.find(params[:id])
      new_nickname = params[:nickname]&.strip

      if new_nickname.present? && user.update(nickname: new_nickname)
        redirect_to admin_users_path, notice: "#{user.username}의 닉네임이 '#{new_nickname}'(으)로 변경되었습니다."
      else
        redirect_to admin_users_path, alert: "닉네임 변경에 실패했습니다."
      end
    end

    def ban
      user = User.find(params[:id])
      reason = params[:reason] || "관리자에 의한 차단"

      user.update(banned: true, banned_at: Time.current, banned_reason: reason)

      conversation = user.conversations.first
      if conversation
        ActionCable.server.broadcast(conversation.channel_name, {
          type: "user_kicked",
          username: user.username
        })
      end

      redirect_to admin_users_path, notice: "#{user.username}이(가) 차단되었습니다."
    end

    def unban
      user = User.find(params[:id])
      user.update(banned: false, banned_at: nil, banned_reason: nil)
      redirect_to admin_users_path, notice: "#{user.username}의 차단이 해제되었습니다."
    end

    def kick
      user = User.find(params[:id])

      conversation = user.conversations.first
      if conversation
        ActionCable.server.broadcast(conversation.channel_name, {
          type: "user_kicked",
          username: user.username
        })
      end

      redirect_to admin_users_path, notice: "#{user.username}이(가) 강제 퇴장되었습니다."
    end

    private

    def user_params
      params.require(:user).permit(:username, :nickname, :password, :password_confirmation)
    end
  end
end
