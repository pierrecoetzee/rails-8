class DueDateReminderJob < ApplicationJob
  queue_as :default

  def perform(task)
    # Simulate sending email/notification
    Rails.logger.info "Sending due date reminder for task: #{task.title} to #{task.user.email_address}"

    # In a real app, you'd send an email here
    # TaskMailer.due_date_reminder(task).deliver_now

    # Store notification in cache for demo purposes
    Rails.cache.write("notification_#{task.id}", {
      message: "Task '#{task.title}' is due tomorrow!",
      created_at: Time.current
    }, expires_in: 1.week)
  end
end