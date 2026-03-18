class FormField < ApplicationRecord
  belongs_to :form

  FIELD_TYPES = %w[text email phone select textarea].freeze

  validates :label, :name, :field_type, presence: true
  validates :field_type, inclusion: { in: FIELD_TYPES }
end
