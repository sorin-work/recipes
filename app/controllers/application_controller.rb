class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private
    # ?servings= from the recipe and cook pages, or the recipe's own servings.
    def requested_servings(recipe)
      servings = params[:servings].to_i
      servings.between?(1, 100) ? servings : recipe.servings
    end

    def render_not_found
      respond_to do |format|
        format.html { render "errors/not_found", status: :not_found }
        format.any { head :not_found }
      end
    end

    def render_bad_request
      respond_to do |format|
        format.html { render "errors/bad_request", status: :bad_request }
        format.any { head :bad_request }
      end
    end
end
