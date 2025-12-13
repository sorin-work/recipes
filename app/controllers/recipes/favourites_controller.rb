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
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            helpers.dom_id(@recipe, :favourite), partial: "recipes/favourite_button", locals: { recipe: @recipe }
          )
        end
        format.html { redirect_back_or_to @recipe }
      end
    end
end
