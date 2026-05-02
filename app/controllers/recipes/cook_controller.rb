# A distraction-free view for cooking: big text, one step at a time, and the
# screen kept awake while it is open.
class Recipes::CookController < ApplicationController
  def show
    @recipe = Current.user.recipes.includes(:ingredients, :steps).find(params[:recipe_id])
    @servings = requested_servings(@recipe)
    @scale = @recipe.scale_for(@servings)
  end
end
