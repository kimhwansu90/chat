class ChatController < ApplicationController
  before_action :require_login
  before_action :require_nickname
  skip_before_action :verify_authenticity_token, only: [:create, :mark_read, :report]

  def index
    @messages = Message.order(created_at: :asc).last(100)
    @nicknames = User.pluck(:username, :nickname).to_h
  end

  def create
    @message = Message.new(
      username: current_user,
      content: params[:content],
      nickname: current_nickname,
      message_type: params[:image].present? ? "image" : "text"
    )

    if params[:image].present?
      @message.image.attach(params[:image])
    end

    if @message.save
      broadcast_data = {
        id: @message.id,
        username: @message.username,
        nickname: current_nickname,
        content: @message.content,
        message_type: @message.message_type,
        created_at: format_message_time(@message.created_at),
        read_count: 1
      }

      if @message.image.attached?
        broadcast_data[:image_url] = @message.image_url
        broadcast_data[:image_thumbnail_url] = @message.image_thumbnail_url
      end

      ActionCable.server.broadcast("chat_channel", broadcast_data)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  def mark_read
    message_ids = params[:message_ids] || []

    message_ids.each do |id|
      ActionCable.server.broadcast("chat_channel", {
        type: "read_receipt",
        message_id: id.to_i,
        read_count: 2
      })
    end

    head :ok
  end

  def report
    message = Message.find_by(id: params[:message_id])

    unless message
      return head :not_found
    end

    report = Report.new(
      reporter_username: current_user,
      reported_username: message.username,
      message: message,
      report_type: params[:report_type] || "inappropriate",
      reason: params[:reason] || "사용자 신고"
    )

    if report.save
      ActionCable.server.broadcast("admin_channel", {
        type: "new_report",
        count: Report.pending.count
      })
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def format_message_time(time)
    time.strftime("%H:%M")
  end
end
