class GroceryListsController < ApplicationController
  include WeekParam

  def show
    @list = GroceryList.new(Current.user, @week)
    @extras = Current.user.grocery_extras.where(week_start: @week.start).order(:created_at)

    respond_to do |format|
      format.html
      format.text do
        send_data @list.to_text, type: "text/plain; charset=utf-8", disposition: "inline",
          filename: "groceries-#{@week.to_param}.txt"
      end
    end
  end
end
