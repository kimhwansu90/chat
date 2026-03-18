class NadKeyword < ApplicationRecord
  belongs_to :nad_ad_group

  MATCH_TYPES = %w[BROAD PHRASE EXACT].freeze
  MATCH_TYPE_LABELS = { "BROAD" => "확장", "PHRASE" => "구문", "EXACT" => "일치" }.freeze

  STATUS_LABELS = {
    "ELIGIBLE" => "게재중",
    "PAUSED" => "일시중지",
    "ENDED" => "종료"
  }.freeze

  def match_type_label
    MATCH_TYPE_LABELS[match_type] || match_type
  end

  def status_label
    STATUS_LABELS[status] || status
  end
end
