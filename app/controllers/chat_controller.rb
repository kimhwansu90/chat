class ChatController < ApplicationController
  # 로그인하지 않은 경우 접근 차단
  before_action :require_login
  # 닉네임이 없는 경우 닉네임 설정 페이지로
  before_action :require_nickname
  # AJAX JSON 요청은 세션 인증으로 충분하므로 CSRF 토큰 검증 제외
  skip_before_action :verify_authenticity_token, only: [:create, :mark_read]
  
  # 채팅 메인 페이지
  def index
    # 최근 100개의 메시지를 시간 순으로 가져오기
    @messages = Message.order(created_at: :asc).last(100)
    
    # 각 메시지에 닉네임 매핑 (세션 기반, 실시간만 가능)
    # 페이지 로드 시에는 username만 표시
    @nicknames = {
      "admin" => "관리자",  # 기본 닉네임
      "user" => "유타지"
    }
  end
  
  # 새 메시지 생성 (AJAX 요청)
  def create
    @message = Message.new(
      username: current_user,      # admin, user 등 (영문만 DB 저장)
      content: params[:content]    # 메시지 내용
    )
    
    if @message.save
      # 메시지 저장 성공: ActionCable을 통해 실시간 브로드캐스트
      # 닉네임은 세션에서 가져와서 브로드캐스트에만 포함 (DB에는 저장 안 함)
      ActionCable.server.broadcast("chat_channel", {
        id: @message.id,
        username: @message.username,      # 소유권 확인용 (영문)
        nickname: current_nickname,       # 표시용 (한글, 실시간 only)
        content: @message.content,
        created_at: format_message_time(@message.created_at),
        read_count: 1 # 항상 1로 표시 (단순화)
      })
      
      head :ok
    else
      # 메시지 저장 실패
      head :unprocessable_entity
    end
  end
  
  # 메시지 읽음 처리 (AJAX 요청) - 단순화 버전
  def mark_read
    # 실제로 DB에 저장하지 않고, 브로드캐스트만 함
    message_ids = params[:message_ids] || []
    
    message_ids.each do |id|
      ActionCable.server.broadcast("chat_channel", {
        type: "read_receipt",
        message_id: id.to_i,
        read_count: 2 # 2명 모두 읽음
      })
    end
    
    head :ok
  end
  
  private
  
  # 메시지 시간 포맷 (시간만 표시)
  def format_message_time(time)
    # 날짜 구분선이 있으므로 시간만 표시
    time.strftime("%H:%M")
  end
end
