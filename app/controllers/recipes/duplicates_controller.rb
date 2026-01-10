class Recipes::DuplicatesController < ApplicationController
  def create
    original = Current.user.recipes.find(params[:recipe_id])
    @recipe = original.duplicate

    if @recipe.save
      redirect_to edit_recipe_path(@recipe), notice: "Copied #{original.title}. Make your changes and save."
    else
      redirect_to original, alert: "Couldn't copy this recipe: #{@recipe.errors.full_messages.to_sentence}"
    end
  end
end
