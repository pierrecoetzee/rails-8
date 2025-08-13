class DashboardController < ApplicationController
  def index
    @recent_tasks = Current.user.tasks.includes(:user).order(created_at: :desc).limit(5)
    @due_soon_tasks = Current.user.tasks.due_soon.limit(5)
    @notifications = get_user_notifications

    if params[:generate_report]
      WeeklyReportJob.perform_later(Current.user)
      redirect_to dashboard_index_path, notice: "Weekly report generation started! Check your email."
    end
  end

  private
  def get_user_notifications
    notifications = []
    cached_notification = Rails.cache.read("user_#{Current.user.id}_notifications")
    notifications << cached_notification if cached_notification
    notifications.flatten!
    notifications.sort_by! { |n| n[:created_at] }
    notifications
  end
end