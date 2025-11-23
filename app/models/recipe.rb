class Recipe < ApplicationRecord
  belongs_to :user
  has_many :ingredients, -> { order(:position) }, dependent: :delete_all, inverse_of: :recipe

  normalizes :title, with: ->(title) { title.squish }

  validates :title, presence: true, length: { maximum: 150 }
  validates :servings, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validates :prep_minutes, :cook_minutes,
    numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2880 }, allow_nil: true
  validates :description, length: { maximum: 2000 }
  validate :ingredient_lines_are_reasonable

  before_save :rebuild_ingredients, if: -> { @ingredients_text }


  def total_minutes
    return if prep_minutes.nil? && cook_minutes.nil?

    prep_minutes.to_i + cook_minutes.to_i
  end

  # The ingredients as one editable line each, the way the form shows them.
  def ingredients_text
    @ingredients_text || ingredients.map(&:to_line).join("\n")
  end

  def ingredients_text=(text)
    @ingredients_text = text.to_s
  end

  private
    def parsed_ingredient_lines
      @parsed_ingredient_lines ||= @ingredients_text.to_s.lines.filter_map { |line| IngredientParser.parse(line) }
    end

    def ingredient_lines_are_reasonable
      return unless @ingredients_text

      lines = parsed_ingredient_lines
      errors.add(:ingredients_text, "has too many lines (100 at most)") if lines.size > 100
      if lines.any? { |line| line.name.length > 200 || line.note.to_s.length > 200 }
        errors.add(:ingredients_text, "has a line that is too long")
      end
    end

    def rebuild_ingredients
      @parsed_ingredient_lines = nil
      ingredients.delete_all
      parsed_ingredient_lines.each.with_index(1) do |line, position|
        ingredients.build(quantity: line.quantity, unit: line.unit, name: line.name, note: line.note, position: position)
      end
      @ingredients_text = nil
    end
end
