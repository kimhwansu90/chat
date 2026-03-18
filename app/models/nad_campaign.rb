class NadCampaign < ApplicationRecord
  belongs_to :nad_account
  has_many :nad_ad_groups, dependent: :destroy

  TYPES = %w[BRAND_SEARCH SHOPPING POWER_LINK POWER_CONTENTS].freeze
  STATUSES = %w[ELIGIBLE PAUSED BUDGET_LIMITED ENDED].freeze

  STATUS_LABELS = {
    "ELIGIBLE" => "게재중",
    "PAUSED" => "일시중지",
    "BUDGET_LIMITED" => "예산한도",
    "ENDED" => "종료"
  }.freeze

  scope :eligible, -> { where(status: "ELIGIBLE") }

  def status_label
    STATUS_LABELS[status] || status
  end

  def budget_formatted
    return "-" if budget.nil?
    "#{budget.to_s(:delimited)}원"
  rescue
    "#{budget}원"
  end
end
