module Admin
  class UsersController < BaseController
    before_action :require_admin
    before_action :set_user, only: [:edit, :update, :destroy]

    def index
      @users = User.order(:role, :username)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)
      if @user.role == "admin"
        @user.errors.add(:role, "관리자 계정은 생성할 수 없습니다")
        return render :new, status: :unprocessable_entity
      end

      if @user.save
        redirect_to admin_users_path, notice: "#{@user.nickname} 계정이 생성되었습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      update_params = user_params
      update_params = update_params.except(:password, :password_confirmation) if update_params[:password].blank?

      if update_params[:role] == "admin"
        @user.errors.add(:role, "관리자 역할은 설정할 수 없습니다")
        return render :edit, status: :unprocessable_entity
      end

      if @user.update(update_params)
        redirect_to admin_users_path, notice: "#{@user.nickname} 정보가 수정되었습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @user == current_user_record
        return redirect_to admin_users_path, alert: "본인 계정은 삭제할 수 없습니다."
      end
      @user.destroy
      redirect_to admin_users_path, notice: "#{@user.nickname} 계정이 삭제되었습니다."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:username, :nickname, :email, :phone, :role, :active,
                                   :password, :password_confirmation)
    end
  end
end
