module RecipesHelper
  # The amount part of an ingredient line, scaled. Marked up so the servings
  # control can rescale it in the browser without a round trip.
  def ingredient_amount(ingredient, scale = 1)
    return if ingredient.quantity.nil?

    unit = ingredient.unit_object
    tag.span(class: "ingredient__amount", data: {
      scale_target: "amount",
      quantity: ingredient.quantity.to_f,
      unit: unit&.singular,
      unit_plural: unit&.plural,
      style: Quantity.style_for(unit)
    }) { ingredient.amount(scale) }
  end

  # Query params for the current list, with +changes+ applied.
  def recipe_list_params(**changes)
    { page: changes[:page] }.compact
  end
end
