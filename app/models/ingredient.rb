class Ingredient < ApplicationRecord
  belongs_to :recipe

  validates :name, presence: true, length: { maximum: 200 }
  validates :note, length: { maximum: 200 }
  validates :unit, inclusion: { in: ->(_) { Unit.codes } }, allow_nil: true
  validates :quantity, numericality: { greater_than: 0, less_than: 100_000 }, allow_nil: true

  scope :items, -> { where(heading: false) }

  def unit_object
    Unit.find(unit)
  end

  # Quantity multiplied by +factor+, as a Rational so repeated scaling stays exact.
  def scaled_quantity(factor = 1)
    quantity && quantity.to_r * factor
  end

  # "1 1/2 cups flour, sifted" - the line as it would be typed.
  def to_line(factor = 1)
    return "#{name}:" if heading?

    [ amount(factor), name ].compact_blank.join(" ") + (note.present? ? ", #{note}" : "")
  end

  # "1 1/2 cups" or "250 g", or nil when there is no quantity.
  def amount(factor = 1)
    value = scaled_quantity(factor)
    return if value.nil?

    unit_label = unit_object&.label_for(value)
    [ Quantity.format(value, unit_object), unit_label ].compact.join(" ")
  end
end
