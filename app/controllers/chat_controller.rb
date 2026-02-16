class ChatController < ApplicationController
  # 로그인하지 않은 경우 접근 차단
  before_action :require_login
  
  # 채팅 메인 페이지
  def index
    # 최근 100개의 메시지를 시간 순으로 가져오기
    @messages = Message.order(created_at: :asc).last(100)
    
    # 상대방이 보낸 모든 메시지를 읽음 처리
    @messages.each do |message|
      if message.username != current_user
        message.mark_as_read_by(current_user)
      end
    end
  end
  
  # 새 메시지 생성 (AJAX 요청)
  def create
    @message = Message.new(
      username: current_user,
      content: params[:content],
      read_by_users: [current_user] # 보낸 사람은 자동으로 읽음 처리
    )
    
    if @message.save
      # 메시지 저장 성공: ActionCable을 통해 실시간 브로드캐스트
      ActionCable.server.broadcast("chat_channel", {
        id: @message.id,
        username: @message.username,
        content: @message.content,
        created_at: format_message_time(@message.created_at),
        read_count: 1 # 보낸 사람만 읽음
      })
      
      head :ok
    else
      # 메시지 저장 실패
      head :unprocessable_entity
    end
  end
  
  # 메시지 읽음 처리 (AJAX 요청)
  def mark_read
    message_ids = params[:message_ids] || []
    
    message_ids.each do |id|
      message = Message.find_by(id: id)
      if message && message.username != current_user
        message.mark_as_read_by(current_user)
        
        # 읽음 상태 브로드캐스트
        ActionCable.server.broadcast("chat_channel", {
          type: "read_receipt",
          message_id: message.id,
          read_count: message.read_count_except_sender + 1
        })
      end
    end
    
    head :ok
  end
  
  private
  
  # 메시지 시간 포맷 (날짜, 요일 포함)
  def format_message_time(time)
    # 한글 요일 배열
    weekdays = ['일', '월', '화', '수', '목', '금', '토']
    weekday = weekdays[time.wday]
    
    if time.to_date == Date.today
      # 오늘이면 시간만 표시
      time.strftime("%H:%M")
    elsif time.to_date == Date.today - 1
      # 어제면 "어제" 표시
      "어제 #{time.strftime('%H:%M')}"
    else
      # 그 외에는 날짜, 요일, 시간 모두 표시
      time.strftime("%m월 %d일 (#{weekday}) %H:%M")
    end
  end
end
