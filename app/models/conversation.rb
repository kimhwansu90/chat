class Conversation < ApplicationRecord
  belongs_to :user

  has_many :messages, -> { order(created_at: :asc) }, dependent: :destroy

  validates :user_id, uniqueness: true

  def admin
    User.find_by(role: "admin")
  end

  def other_participant(current_username)
    current_username == admin&.username ? user : admin
  end

  def last_message
    messages.order(created_at: :desc).first
  end

  def channel_name
    "conversation_#{id}"
  end

  def reset_unread_for!(role)
    if role == "admin"
      update_column(:admin_unread_count, 0)
    else
      update_column(:user_unread_count, 0)
    end
  end

  def increment_unread_for!(role)
    if role == "admin"
      self.class.where(id: id).update_all("admin_unread_count = admin_unread_count + 1")
    else
      self.class.where(id: id).update_all("user_unread_count = user_unread_count + 1")
    end
  end
end
