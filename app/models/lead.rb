class Lead < ApplicationRecord
  STATUSES = %w[new contacted quoted converted lost].freeze
  STATUS_LABELS = {
    "new" => "신규",
    "contacted" => "상담중",
    "quoted" => "견적",
    "converted" => "계약",
    "lost" => "실패"
  }.freeze

  belongs_to :form, optional: true
  belongs_to :assigned_to, class_name: "User", optional: true
  has_many :activities, class_name: "LeadActivity", dependent: :destroy

  validates :name, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :by_status, ->(status) { where(status: status) }
  scope :unassigned, -> { where(assigned_to: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def status_label
    STATUS_LABELS[status]
  end

  def change_status!(new_status, user:)
    return if status == new_status

    old_status = status
    update!(status: new_status)
    activities.create!(
      activity_type: "status_change",
      user: user,
      content: "#{STATUS_LABELS[old_status]} → #{STATUS_LABELS[new_status]}",
      metadata: { from: old_status, to: new_status }
    )
  end

  def assign_to!(sales_rep, assigned_by:)
    update!(assigned_to: sales_rep)
    activities.create!(
      activity_type: "assignment",
      user: assigned_by,
      content: "#{sales_rep.nickname}에게 배정"
    )
  end
end
