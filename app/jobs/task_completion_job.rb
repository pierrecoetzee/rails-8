class TaskCompletionJob < ApplicationJob
  queue_as :default

  def perform(task)
    Rails.logger.info "Task completed: #{task.title}"

    # Clear any cached data related to this task
    Rails.cache.delete("project_#{task.projects.first&.id}_completion")

    # Update user stats in cache
    user_stats = Rails.cache.fetch("user_#{task.user.id}_stats", expires_in: 1.hour) do
      {
        total_tasks: task.user.tasks.count,
        completed_tasks: task.user.tasks.completed.count,
        pending_tasks: task.user.tasks.pending.count
      }
    end

    # Increment completed tasks counter
    user_stats[:completed_tasks] += 1
    user_stats[:pending_tasks] -= 1

    Rails.cache.write("user_#{task.user.id}_stats", user_stats, expires_in: 1.hour)
  end
end