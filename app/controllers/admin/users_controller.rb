module Admin
  class UsersController < BaseController
    before_action :require_admin

    def index
      @users = User.order(:role, :username)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_users_path, notice: "#{@user.nickname} 계정이 생성되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])

      update_params = user_params
      update_params = update_params.except(:password, :password_confirmation) if update_params[:password].blank?

      if @user.update(update_params)
        redirect_to admin_users_path, notice: "#{@user.nickname} 정보가 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user).permit(:username, :nickname, :email, :phone, :role, :active,
                                   :password, :password_confirmation)
    end
  end
end
