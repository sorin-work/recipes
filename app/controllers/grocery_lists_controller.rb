class GroceryListsController < ApplicationController
  include WeekParam

  def show
    @list = GroceryList.new(Current.user, @week)
    @extras = Current.user.grocery_extras.where(week_start: @week.start).order(:created_at)

    render
  end
end
