class PlansController < ApplicationController
  include WeekParam

  def show
    @entries = Current.user.meal_plan_entries.in_week(@week).includes(:recipe).ordered
      .group_by { |entry| [ entry.on, entry.meal ] }
    @recipes = Current.user.recipes.order(favourite: :desc, title: :asc)
  end

  def copy_previous_week
    copied = 0
    MealPlanEntry.transaction do
      existing = Current.user.meal_plan_entries.in_week(@week).pluck(:recipe_id, :on, :meal).to_set
      Current.user.meal_plan_entries.in_week(@week.previous).find_each do |entry|
        attributes = { recipe_id: entry.recipe_id, on: entry.on + 7, meal: entry.meal }
        next if existing.include?(attributes.values)

        Current.user.meal_plan_entries.create!(attributes.merge(servings: entry.servings))
        copied += 1
      end
    end

    redirect_to plan_path(week: @week), notice: copied.zero? ? "Nothing new to copy from last week." : "Copied #{helpers.pluralize(copied, 'meal')} from last week."
  end

  def clear
    removed = Current.user.meal_plan_entries.in_week(@week).delete_all
    redirect_to plan_path(week: @week), notice: "Removed #{helpers.pluralize(removed, 'meal')} from this week.", status: :see_other
  end
end
