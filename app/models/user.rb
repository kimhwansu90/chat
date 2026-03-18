class User < ApplicationRecord
  has_secure_password

  ROLES = %w[admin manager team1 team2 sales_rep].freeze
  ROLE_LABELS = {
    "admin"    => "관리자",
    "manager"  => "팀장",
    "team1"    => "1팀",
    "team2"    => "2팀",
    "sales_rep" => "영업"
  }.freeze

  validates :username, presence: true, uniqueness: true
  validates :nickname, presence: true
  validates :role, inclusion: { in: ROLES }
  validates :email, uniqueness: true, allow_nil: true

  has_many :assigned_leads, class_name: "Lead", foreign_key: :assigned_to_id, dependent: :nullify

  scope :active, -> { where(active: true) }
  scope :sales_reps, -> { where(role: %w[sales_rep team1 team2]) }
  scope :managers_and_above, -> { where(role: %w[admin manager]) }

  def admin?
    role == "admin"
  end

  def manager?
    role == "manager"
  end

  def sales_rep?
    role == "sales_rep"
  end

  def manager_or_above?
    admin? || manager?
  end

  def banned?
    banned == true
  end

  def touch_last_seen!
    update_column(:last_seen_at, Time.current)
  end
end
