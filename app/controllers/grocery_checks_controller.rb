class GroceryChecksController < ApplicationController
  include WeekParam

  def create
    Current.user.grocery_checks.find_or_create_by!(week_start: @week.start, item_key: item_key)
    redirect_to grocery_list_path(week: @week), status: :see_other
  end

  def destroy
    Current.user.grocery_checks.where(week_start: @week.start, item_key: item_key).delete_all
    redirect_to grocery_list_path(week: @week), status: :see_other
  end

  private
    def item_key
      params.require(:item_key).to_s.first(200)
    end
end
