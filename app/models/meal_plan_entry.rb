class MealPlanEntry < ApplicationRecord
  MEALS = %w[breakfast lunch dinner snack].freeze

  belongs_to :user
  belongs_to :recipe

  enum :meal, MEALS.index_with(&:itself), validate: true

  before_validation -> { self.servings = recipe.servings if recipe }, on: :create

  validates :on, presence: true
  validates :servings, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 100 }
  validate :recipe_belongs_to_user

  scope :in_week, ->(week) { where(on: week.days) }
  scope :ordered, -> { order(:on, Arel.sql(meal_order_sql), :created_at) }

  def self.meal_order_sql
    "CASE meal " + MEALS.each_with_index.map { |meal, i| "WHEN '#{meal}' THEN #{i}" }.join(" ") + " END"
  end

  # Multiplier for the recipe's quantities to cook this many servings.
  def scale
    recipe.scale_for(servings)
  end

  private
    def recipe_belongs_to_user
      errors.add(:recipe, "is not one of your recipes") if recipe && user && recipe.user_id != user_id
    end
end
