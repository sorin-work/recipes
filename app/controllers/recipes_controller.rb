class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show edit update destroy ]

  def index
    @sort = Recipe::SORTS.key?(params[:sort]) ? params[:sort] : "newest"
    scope = Current.user.recipes.sorted(@sort)
    scope = scope.search(params[:q]) if params[:q].present?
    scope = scope.tagged(params[:tag]) if params[:tag].present?
    scope = scope.favourites if params[:favourites] == "1"
    @total = scope.count
    # A page past the end (after deleting recipes, or an old link) shows the last page.
    @page = params[:page].to_i.clamp(1, [ (@total.to_f / Recipe::PER_PAGE).ceil, 1 ].max)
    @recipes = scope.limit(Recipe::PER_PAGE).offset((@page - 1) * Recipe::PER_PAGE)
    @tags = Current.user.tags.where(id: Tagging.select(:tag_id)).order(:name)
  end

  def show
    @servings = requested_servings(@recipe)
    @scale = @recipe.scale_for(@servings)
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
    @recipe.photo.purge_later if params.dig(:recipe, :remove_photo) == "1"
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
        :source_url,
        :ingredients_text,
        :steps_text,
        :tag_list,
        :photo,
        :title, :description, :servings, :prep_minutes, :cook_minutes
      ])
    end
end
