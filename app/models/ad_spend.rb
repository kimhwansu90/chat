class AdSpend < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  CHANNELS = %w[naver meta kakao google 기타].freeze

  validates :channel, :campaign_name, :amount, :period_start, :period_end, presence: true
  validates :channel, inclusion: { in: CHANNELS }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validate :period_end_after_start

  scope :in_period, ->(from, to) {
    where("period_start <= ? AND period_end >= ?", to, from)
  }
  scope :recent, -> { order(period_start: :desc) }

  private

  def period_end_after_start
    return unless period_start && period_end
    errors.add(:period_end, "은 시작일 이후여야 합니다") if period_end < period_start
  end
end
