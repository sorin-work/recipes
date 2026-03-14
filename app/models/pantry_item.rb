# Something already in the cupboard. Without a quantity it is a staple that is
# always there (salt, olive oil) and never goes on the grocery list.
class PantryItem < ApplicationRecord
  belongs_to :user

  normalizes :name, with: ->(name) { name.squish }
  before_validation -> { self.name_key = IngredientName.key(name) }

  validates :name, presence: true, length: { maximum: 100 }
  validates :name_key, uniqueness: { scope: :user_id, message: "is already in your pantry" }
  validates :quantity, numericality: { greater_than: 0, less_than: 100_000 }, allow_nil: true
  validates :unit, inclusion: { in: ->(_) { Unit.codes }, message: "isn't a unit we know (try g, ml, tsp, cup or can)" },
    allow_nil: true
  validate :unit_needs_a_quantity

  scope :alphabetical, -> { order(:name) }

  normalizes :unit, with: ->(unit) { Unit.find(unit)&.code || unit.strip.presence }

  def staple?
    quantity.nil?
  end

  def unit_object
    Unit.find(unit)
  end

  def amount
    return if staple?

    [ Quantity.format(quantity, unit_object), unit_object&.label_for(quantity) ].compact.join(" ")
  end

  def key
    name_key.presence || IngredientName.key(name)
  end

  # Lets the form take "500 g" or "2 cans" in one field.
  def amount_text=(text)
    text = text.to_s.strip
    if text.empty?
      self.quantity = nil
      self.unit = nil
      return
    end

    value, rest = Quantity.scan(text)
    self.quantity = value
    self.unit = value ? rest.presence : text
  end

  def amount_text
    amount
  end

  private
    def unit_needs_a_quantity
      errors.add(:quantity, "is needed when a unit is given") if unit.present? && quantity.nil?
    end
end
