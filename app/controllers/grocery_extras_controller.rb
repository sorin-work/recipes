class GroceryExtrasController < ApplicationController
  include WeekParam
  before_action :set_extra, only: %i[ update destroy ]

  def create
    extra = Current.user.grocery_extras.new(name: params.expect(grocery_extra: [ :name ])[:name], week_start: @week.start)
    if extra.save
      redirect_to grocery_list_path(week: @week), status: :see_other
    else
      redirect_to grocery_list_path(week: @week), alert: "Extra item #{extra.errors.full_messages.to_sentence.downcase_first}."
    end
  end

  def update
    @extra.update!(checked: params.dig(:grocery_extra, :checked) == "1")
    redirect_to grocery_list_path(week: Week.new(@extra.week_start)), status: :see_other
  end

  def destroy
    @extra.destroy!
    redirect_to grocery_list_path(week: Week.new(@extra.week_start)), status: :see_other
  end

  private
    def set_extra
      @extra = Current.user.grocery_extras.find(params[:id])
    end
end
