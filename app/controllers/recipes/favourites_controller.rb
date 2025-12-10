class Recipes::FavouritesController < ApplicationController
  before_action :set_recipe

  def create
    @recipe.update!(favourite: true)
    respond
  end

  def destroy
    @recipe.update!(favourite: false)
    respond
  end

  private
    def set_recipe
      @recipe = Current.user.recipes.find(params[:recipe_id])
    end

    def respond
      redirect_to @recipe
    end
end
