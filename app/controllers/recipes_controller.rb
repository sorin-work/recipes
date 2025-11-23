class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show edit update destroy ]

  def index
    @recipes = Current.user.recipes.order(created_at: :desc)
  end

  def show
  end

  def new
    @recipe = Current.user.recipes.new(servings: 4)
  end

  def edit
  end

  def create
    @recipe = Current.user.recipes.new(recipe_params)

    if @recipe.save
      redirect_to @recipe, notice: "Recipe saved."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "Recipe updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy!
    redirect_to recipes_path, notice: "Deleted #{@recipe.title}.", status: :see_other
  end

  private
    def set_recipe
      @recipe = Current.user.recipes.find(params[:id])
    end

    def recipe_params
      params.expect(recipe: [
        :ingredients_text,
        :title, :description, :servings, :prep_minutes, :cook_minutes
      ])
    end
end
