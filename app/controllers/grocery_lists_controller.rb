class GroceryListsController < ApplicationController
  include WeekParam

  def show
    @list = GroceryList.new(Current.user, @week)

    render
  end
end
