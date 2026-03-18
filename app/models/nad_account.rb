class NadAccount < ApplicationRecord
  has_many :nad_campaigns, dependent: :destroy
  has_many :nad_reports, dependent: :destroy

  validates :name, presence: true
  validates :customer_id, presence: true, uniqueness: true

  attr_encrypted :api_key,
    key: -> { Rails.application.secret_key_base[0, 32] },
    encode: true
  attr_encrypted :api_secret,
    key: -> { Rails.application.secret_key_base[0, 32] },
    encode: true

  scope :active, -> { where(active: true) }

  def sync!
    NaverAds::CampaignSync.call(self)
    update!(last_synced_at: Time.current)
  end

  def display_name
    "#{name} (#{customer_id})"
  end

  def api_key_masked
    return nil if api_key.blank?
    api_key[0, 6] + "*" * 10
  end
end
