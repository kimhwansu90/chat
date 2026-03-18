class NadReport < ApplicationRecord
  belongs_to :nad_account

  REPORT_TYPES = %w[campaign ad_group keyword].freeze

  scope :for_date_range, ->(from, to) { where(report_date: from..to) }
  scope :campaigns, -> { where(report_type: "campaign") }
  scope :by_date, -> { order(report_date: :desc) }

  def ctr
    return 0 if impressions.zero?
    (clicks.to_f / impressions * 100).round(2)
  end

  def cpc
    return 0 if clicks.zero?
    (cost.to_f / clicks).round(0).to_i
  end

  def cost_per_conversion
    return 0 if conversions.zero?
    (cost.to_f / conversions).round(0).to_i
  end

  def cost_formatted
    "#{cost.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse}원"
  end
end
