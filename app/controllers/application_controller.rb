class ApplicationController < ActionController::Base
  include Authentication

  before_action :log_session_info

  private

  def log_session_info
    Rails.logger.info "Session ID: #{cookies.encrypted[:session_id] || cookies.signed[:session_id]}"
    Rails.logger.info "Current user: #{Current.user&.id}"
  end


  def current_user_stats
    return {} unless Current.user

    # Solid cache with shorter expiry for more real-time updates
    @current_user_stats ||= Rails.cache.fetch("user_#{Current.user.id}_stats", expires_in: 5.minutes) do
      {
        total_tasks: Current.user.tasks.count,
        completed_tasks: Current.user.tasks.completed.count,
        pending_tasks: Current.user.tasks.pending.count,
        total_projects: Current.user.projects.count
      }
    end
  end
  helper_method :current_user_stats
end