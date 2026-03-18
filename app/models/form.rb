class Form < ApplicationRecord
  has_many :form_fields, -> { order(:position) }, dependent: :destroy, inverse_of: :form
  has_many :leads, dependent: :nullify
  belongs_to :created_by, class_name: "User", optional: true

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9\-]+\z/, message: "은(는) 소문자, 숫자, 하이픈만 허용됩니다" }

  accepts_nested_attributes_for :form_fields, allow_destroy: true,
    reject_if: proc { |attrs| attrs["label"].blank? }

  scope :active, -> { where(active: true) }

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    self.slug = name&.parameterize if slug.blank?
  end
end
