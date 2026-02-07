class MealPlanEntriesController < ApplicationController
  before_action :set_entry, only: %i[ update destroy ]

  def create
    @entry = Current.user.meal_plan_entries.new(entry_params.except(:recipe_id))
    @entry.recipe = Current.user.recipes.find(entry_params[:recipe_id])

    if @entry.save
      respond_with_cells([ [ @entry.on, @entry.meal ] ], notice: "Added #{@entry.recipe.title} to #{day_and_meal(@entry)}.")
    else
      redirect_back_or_to plan_path(week: Week.new(@entry.on || Date.current)),
        alert: "Couldn't add that: #{@entry.errors.full_messages.to_sentence}."
    end
  end

  # Moving an entry to another day or meal, or changing its servings.
  def update
    from = [ @entry.on, @entry.meal ]
    if @entry.update(entry_params.except(:recipe_id))
      respond_with_cells([ from, [ @entry.on, @entry.meal ] ].uniq, notice: "Updated #{@entry.recipe.title}.")
    else
      redirect_back_or_to plan_path(week: Week.new(from.first)),
        alert: "Couldn't update that: #{@entry.errors.full_messages.to_sentence}."
    end
  end

  def destroy
    @entry.destroy!
    respond_with_cells([ [ @entry.on, @entry.meal ] ], notice: "Removed #{@entry.recipe.title} from #{day_and_meal(@entry)}.")
  end

  private
    def set_entry
      @entry = Current.user.meal_plan_entries.find(params[:id])
    end

    def entry_params
      params.expect(meal_plan_entry: %i[ recipe_id on meal servings ])
    end

    def day_and_meal(entry)
      "#{entry.on.strftime('%A')} #{entry.meal}"
    end

    # Changes made on the planner re-render just the cells that changed. Anywhere
    # else (the recipe page, or without JavaScript) we go to the planner instead.
    def respond_with_cells(cells, notice:)
      if params[:from_planner].present? && request.format.turbo_stream?
        render turbo_stream: cells.map { |date, meal|
          turbo_stream.replace(helpers.plan_cell_id(date, meal), partial: "plans/cell",
            locals: { date: date, meal: meal, entries: cell_entries(date, meal) })
        }
      else
        redirect_to plan_path(week: Week.new(@entry.on)), notice: notice, status: :see_other
      end
    end

    def cell_entries(date, meal)
      Current.user.meal_plan_entries.where(on: date, meal: meal).includes(:recipe).order(:created_at)
    end
end
