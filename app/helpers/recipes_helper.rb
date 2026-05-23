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

  def source_link(recipe)
    return if recipe.source_url.blank?
    return recipe.source_url unless recipe.source_url.match?(%r{\Ahttps?://}i)

    host = URI.parse(recipe.source_url).host.to_s.delete_prefix("www.")
    link_to host.presence || recipe.source_url, recipe.source_url, rel: "noopener noreferrer nofollow", target: "_blank"
  rescue URI::InvalidURIError
    recipe.source_url
  end

  # Query params for the current list, with +changes+ applied.
  def recipe_list_params(**changes)
    request.query_parameters.symbolize_keys.slice(:q, :tag, :favourites, :sort, :page).merge(changes).compact_blank
  end
end
