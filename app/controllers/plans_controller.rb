class PlansController < ApplicationController
  def show
    @week = Week.parse(params[:week])
    @entries = Current.user.meal_plan_entries.in_week(@week).includes(:recipe).ordered
      .group_by { |entry| [ entry.on, entry.meal ] }
  end
end
