class Report < ApplicationRecord
  belongs_to :message

  validates :reporter_username, :reported_username, :report_type, :reason, presence: true

  scope :pending, -> { where(status: "pending") }
  scope :reviewed, -> { where.not(status: "pending") }
  scope :recent, -> { order(created_at: :desc) }
end
