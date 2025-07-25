class Project < ApplicationRecord
  belongs_to :user
  has_many :task_projects, dependent: :destroy
  has_many :tasks, through: :task_projects

  validates :name, presence: true

  def completion_percentage
    return 0 if tasks.empty?

    Rails.cache.fetch("project_#{id}_completion", expires_in: 5.minutes) do
      completed_tasks = tasks.completed.count
      total_tasks = tasks.count
      (completed_tasks.to_f / total_tasks * 100).round(1)
    end
  end
end