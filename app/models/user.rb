class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, uniqueness: true
  validates :nickname, presence: true

  has_many :conversations, dependent: :destroy

  def admin?
    role == "admin"
  end

  def banned?
    banned == true
  end

  def touch_last_seen!
    update_column(:last_seen_at, Time.current)
  end

  def conversation_with_admin
    conversations.first || conversations.create!(last_message_at: Time.current)
  end
end
