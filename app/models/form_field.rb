class FormField < ApplicationRecord
  belongs_to :form

  FIELD_TYPES = %w[text email phone select textarea privacy_checkbox].freeze

  validates :label, :field_type, presence: true
  validates :name, presence: true, unless: -> { field_type == "privacy_checkbox" }
  validates :field_type, inclusion: { in: FIELD_TYPES }
end
