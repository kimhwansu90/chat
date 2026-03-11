module Admin
  class ConversationsController < BaseController
    def index
      @conversations = Conversation
        .includes(:user)
        .order(Arel.sql("COALESCE(last_message_at, created_at) DESC"))
    end

    def show
      @conversation = Conversation.find(params[:id])
      @conversation.reset_unread_for!("admin")
      @messages = @conversation.messages
        .includes(image_attachment: :blob)
        .order(created_at: :asc)
        .last(100)
      @other_user = @conversation.user

      render "conversations/show", layout: "application"
    end
  end
end
