module PlansHelper
  def plan_cell_id(date, meal)
    "cell-#{date.iso8601}-#{meal}"
  end

  def plan_day_label(date)
    date.strftime("%a %-d %b")
  end
end
