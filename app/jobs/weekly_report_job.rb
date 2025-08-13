class WeeklyReportJob < ApplicationJob
  queue_as :reports

  def perform(user = nil)
    if user
      # Generate report for specific user
      generate_weekly_report(user)
    else
      # Generate reports for all users
      User.find_each do |user|
        generate_weekly_report(user)
      end
    end
  end

  private

  def generate_weekly_report(user)
    report_data = {
      user_id: user.id,
      week_start: 1.week.ago.beginning_of_week,
      completed_tasks: user.tasks.completed.where(updated_at: 1.week.ago..Time.current).count,
      created_tasks: user.tasks.where(created_at: 1.week.ago..Time.current).count,
      overdue_tasks: user.tasks.overdue.count
    }

    Rails.cache.write("weekly_report_#{user.id}", report_data, expires_in: 1.week)
    Rails.logger.info "Generated weekly report for #{user.name}"
  end
end