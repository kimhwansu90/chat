module Admin
  class MessagesController < BaseController
    skip_before_action :verify_authenticity_token, only: [:destroy]

    def index
      @messages = Message.order(created_at: :desc).limit(100)
      @nicknames = User.pluck(:username, :nickname).to_h
    end

    def destroy
      message = Message.find(params[:id])
      message_id = message.id

      message.destroy

      ActionCable.server.broadcast("chat_channel", {
        type: "message_deleted",
        message_id: message_id
      })

      redirect_to admin_messages_path, notice: "메시지가 삭제되었습니다."
    end
  end
end
