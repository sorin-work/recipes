# GET /up for docker healthchecks and uptime monitors: 200 when the app is up
# and can reach the database, 503 when it can't.
class HealthController < ActionController::Base
  def show
    ActiveRecord::Base.connection.select_value("SELECT 1")
    render json: { status: "ok", database: "ok" }
  rescue StandardError => error
    Rails.logger.error("Health check failed: #{error.class}: #{error.message}")
    render json: { status: "error", database: "unavailable" }, status: :service_unavailable
  end
end
