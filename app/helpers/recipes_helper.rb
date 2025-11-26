module RecipesHelper
  # The amount part of an ingredient line, scaled. Marked up so the servings
  # control can rescale it in the browser without a round trip.
  def ingredient_amount(ingredient, scale = 1)
    return if ingredient.quantity.nil?

    unit = ingredient.unit_object
    tag.span(ingredient.amount(scale), class: "ingredient__amount")
  end
end
