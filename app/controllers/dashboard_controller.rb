class DashboardController < ApplicationController
  def show
    @week = Week.current
    entries = Current.user.meal_plan_entries.in_week(@week).includes(:recipe).ordered.to_a
    @today = entries.select { |entry| entry.on == Date.current }
    @coming_up = entries.select { |entry| entry.on > Date.current }
    @planned_days = entries.map(&:on).uniq.size
    @favourites = Current.user.recipes.favourites.order(:title).limit(6)
    @recent = Current.user.recipes.order(created_at: :desc).limit(6)
    @recipe_count = Current.user.recipes.count
    @to_buy = GroceryList.new(Current.user, @week).to_buy.count
  end
end
