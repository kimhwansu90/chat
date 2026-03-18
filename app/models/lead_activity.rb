class LeadActivity < ApplicationRecord
  belongs_to :lead
  belongs_to :user, optional: true

  ACTIVITY_TYPES = %w[status_change note call email assignment].freeze

  validates :activity_type, inclusion: { in: ACTIVITY_TYPES }

  scope :recent, -> { order(created_at: :desc) }
end
