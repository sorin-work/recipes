class MealPlanEntriesController < ApplicationController
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

  private

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
