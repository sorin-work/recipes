module PlansHelper
  def plan_cell_id(date, meal)
    "cell-#{date.iso8601}-#{meal}"
  end

  def plan_day_label(date)
    date.strftime("%a %-d %b")
  end

  # Recipes for the "add" menu in each planner cell, loaded once per page.
  def plan_recipe_options
    @plan_recipe_options ||= Current.user.recipes.order(:title).pluck(:title, :id)
  end
end
