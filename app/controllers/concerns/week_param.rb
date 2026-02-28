# Reads ?week=YYYY-MM-DD into @week for pages that show one week at a time.
module WeekParam
  extend ActiveSupport::Concern

  included do
    before_action :set_week
  end

  private
    def set_week
      @week = Week.parse(params[:week])
    end
end
