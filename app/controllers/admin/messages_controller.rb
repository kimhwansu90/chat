module Admin
  class MessagesController < BaseController
    skip_before_action :verify_authenticity_token, only: [:destroy]

    def index
      @messages = Message.where.not(conversation_id: nil).order(created_at: :desc).limit(100)
      @nicknames = User.pluck(:username, :nickname).to_h
    end

    def destroy
      message = Message.find(params[:id])
      message_id = message.id
      conversation = message.conversation

      message.destroy

      if conversation
        ActionCable.server.broadcast(conversation.channel_name, {
          type: "message_deleted",
          message_id: message_id
        })
      end

      redirect_to admin_messages_path, notice: "메시지가 삭제되었습니다."
    end
  end
end
