class ChatChannel < ApplicationCable::Channel
  # 클라이언트가 채널에 연결될 때 호출
  def subscribed
    # "chat_channel" 스트림 구독
    # 이 채널로 브로드캐스트되는 모든 메시지를 받습니다
    stream_from "chat_channel"
  end

  # 클라이언트가 채널 연결을 끊을 때 호출
  def unsubscribed
    # 정리 작업이 필요한 경우 여기에 작성
    # 현재는 특별한 정리 작업이 없음
  end
end
