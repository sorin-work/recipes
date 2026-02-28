class GroceryListsController < ApplicationController
  def show
    @week = Week.parse(params[:week])
    @list = GroceryList.new(Current.user, @week)

    render
  end
end
