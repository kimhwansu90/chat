class NadAdGroup < ApplicationRecord
  belongs_to :nad_campaign
  has_many :nad_keywords, dependent: :destroy

  STATUS_LABELS = {
    "ELIGIBLE" => "게재중",
    "PAUSED" => "일시중지",
    "ENDED" => "종료"
  }.freeze

  def status_label
    STATUS_LABELS[status] || status
  end
end
