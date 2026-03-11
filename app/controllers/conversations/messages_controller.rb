module Conversations
  class MessagesController < ApplicationController
    before_action :require_login
    skip_before_action :verify_authenticity_token, only: [:create]

    def create
      conversation = Conversation.find(params[:conversation_id])

      unless authorized_for?(conversation)
        return head :forbidden
      end

      message = conversation.messages.new(
        username: current_user,
        nickname: current_nickname,
        content: params[:content],
        message_type: params[:image].present? ? "image" : "text"
      )

      if params[:image].present?
        message.image.attach(params[:image])
      end

      if message.save
        conversation.update_column(:last_message_at, message.created_at)

        if current_user_record.admin?
          conversation.increment_unread_for!("user")
        else
          conversation.increment_unread_for!("admin")
        end

        broadcast_data = {
          id: message.id,
          username: message.username,
          nickname: current_nickname,
          content: message.content,
          message_type: message.message_type,
          created_at: message.created_at.strftime("%H:%M")
        }

        if message.image.attached?
          broadcast_data[:image_url] = message.image_url
          broadcast_data[:image_thumbnail_url] = message.image_thumbnail_url
        end

        ActionCable.server.broadcast(conversation.channel_name, broadcast_data)

        unless current_user_record.admin?
          ActionCable.server.broadcast("admin_conversations", {
            type: "new_message",
            conversation_id: conversation.id,
            user_nickname: conversation.user.nickname,
            preview: (message.content || "[이미지]").truncate(30),
            unread_count: conversation.reload.admin_unread_count,
            last_message_at: message.created_at.strftime("%H:%M")
          })
        end

        head :ok
      else
        head :unprocessable_entity
      end
    end

    private

    def authorized_for?(conversation)
      current_user_record.admin? || conversation.user_id == current_user_record.id
    end
  end
end
