class User < ApplicationRecord
  validates :username, presence: true, uniqueness: true

  def admin?
    role == "admin"
  end

  def banned?
    banned == true
  end

  def touch_last_seen!
    update_column(:last_seen_at, Time.current)
  end
end
