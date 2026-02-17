module Admin
  class AnnouncementsController < BaseController
    skip_before_action :verify_authenticity_token, only: [:create]

    def new
    end

    def create
      content = params[:content]&.strip

      if content.blank?
        flash.now[:alert] = "공지 내용을 입력해주세요."
        render :new, status: :unprocessable_entity
        return
      end

      message = Message.create!(
        username: "system",
        nickname: "시스템",
        content: content,
        message_type: "system"
      )

      ActionCable.server.broadcast("chat_channel", {
        id: message.id,
        username: "system",
        nickname: "시스템",
        content: content,
        message_type: "system",
        created_at: message.created_at.strftime("%H:%M"),
        read_count: 0
      })

      redirect_to admin_root_path, notice: "공지가 전송되었습니다."
    end
  end
end
