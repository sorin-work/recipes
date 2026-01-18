# Paste a recipe as text, check what was read in the normal recipe form, save.
class Recipes::ImportsController < ApplicationController
  def new
    @import = RecipeImport.new
  end

  def create
    @import = RecipeImport.new(text: params.expect(recipe_import: [ :text ])[:text])

    if @import.valid?
      @recipe = Current.user.recipes.new({ servings: 4 }.merge(@import.recipe_attributes))
      flash.now[:notice] = "Here's what we found. Check it over, then save."
      render "recipes/new", status: :unprocessable_entity
    else
      render :new, status: :unprocessable_entity
    end
  end
end
