class Message < ApplicationRecord
  # 읽음 상태를 JSON 형태로 저장 (배열 형태로 사용자 이름 저장)
  serialize :read_by_users, coder: JSON
  
  # 초기화 시 빈 배열로 설정
  after_initialize :set_defaults
  
  # 특정 사용자가 메시지를 읽었는지 확인
  def read_by?(username)
    (read_by_users || []).include?(username)
  end
  
  # 사용자가 메시지를 읽음 처리
  def mark_as_read_by(username)
    self.read_by_users ||= []
    self.read_by_users << username unless read_by_users.include?(username)
    save
  end
  
  # 읽음 표시 개수 (보낸 사람 제외)
  def read_count_except_sender
    return 0 unless read_by_users
    (read_by_users - [username]).size
  end
  
  private
  
  def set_defaults
    self.read_by_users ||= []
  end
end
