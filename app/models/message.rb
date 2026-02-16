class Message < ApplicationRecord
  # read_by_users 필드는 DB에 저장하지 않고 메모리에서만 사용
  attr_accessor :read_by_memory
  
  after_initialize :set_defaults
  
  # 읽음 표시 개수 (항상 0으로 반환 - 실시간 전용)
  def read_count_except_sender
    0  # 간단하게 항상 1명만 읽음으로 표시
  end
  
  private
  
  def set_defaults
    self.read_by_memory ||= []
  end
end
