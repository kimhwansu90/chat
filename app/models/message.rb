class Message < ApplicationRecord
  belongs_to :conversation, optional: true
  has_one_attached :image

  validate :acceptable_image, if: -> { image.attached? }

  scope :recent, -> { order(created_at: :desc) }

  def image_url
    return nil unless image.attached?
    Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
  end

  def image_thumbnail_url
    return nil unless image.attached?
    Rails.application.routes.url_helpers.rails_representation_path(
      image.variant(resize_to_limit: [400, 400]),
      only_path: true
    )
  end

  private

  def acceptable_image
    unless image.blob.content_type.in?(%w[image/jpeg image/png image/gif image/webp])
      errors.add(:image, "은(는) JPEG, PNG, GIF, WebP만 허용됩니다")
    end

    if image.blob.byte_size > 10.megabytes
      errors.add(:image, "은(는) 10MB 이하여야 합니다")
    end
  end
end
