class Project < ApplicationRecord
  belongs_to :user
  has_many :task_projects, dependent: :destroy
  has_many :tasks, through: :task_projects

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, length: { maximum: 1000 }

  scope :with_tasks, -> { includes(:tasks) }

  # Cache completion percentage using Solid Cache
  def task_completion_percentage
    return 0 if tasks.count == 0

    Rails.cache.fetch("project_#{id}_completion", expires_in: 5.minutes) do
      completed_tasks = tasks.completed.count
      total_tasks = tasks.count
      (completed_tasks.to_f / total_tasks * 100).round(1)
    end
  end

  # Cache task counts for better performance
  def tasks_count
    Rails.cache.fetch("project_#{id}_tasks_count", expires_in: 5.minutes) do
      tasks.count
    end
  end

  def completed_tasks_count
    Rails.cache.fetch("project_#{id}_completed_tasks_count", expires_in: 5.minutes) do
      tasks.completed.count
    end
  end

  def pending_tasks_count
    Rails.cache.fetch("project_#{id}_pending_tasks_count", expires_in: 5.minutes) do
      tasks.pending.count
    end
  end

  def in_progress_tasks_count
    Rails.cache.fetch("project_#{id}_in_progress_tasks_count", expires_in: 5.minutes) do
      tasks.in_progress.count
    end
  end

  # Method to clear all cached data for this project
  def clear_cache!
    Rails.cache.delete("project_#{id}_completion")
    Rails.cache.delete("project_#{id}_tasks_count")
    Rails.cache.delete("project_#{id}_completed_tasks_count")
    Rails.cache.delete("project_#{id}_pending_tasks_count")
    Rails.cache.delete("project_#{id}_in_progress_tasks_count")
    Task.statuses.entries.each do |status, _|
      Rails.cache.delete("project_#{id}_tasks__#{status}")
      end
  end

  # Callback to clear cache when tasks are modified
  after_update :clear_cache!

  private

  # Clear cache when the project is updated
  def clear_cache_on_task_changes
    clear_cache!
  end
end