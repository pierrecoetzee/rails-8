class Task < ApplicationRecord
  belongs_to :user
  has_many :task_projects, dependent: :destroy
  has_many :projects, through: :task_projects

  enum :status, { pending: 0, in_progress: 1, completed: 2, cancelled: 3 }
  enum :priority, { low: 0, medium: 1, high: 2, urgent: 3 }

  validates :title, presence: true
  validates :status, presence: true
  validates :priority, presence: true
  validates :description, presence: true

  scope :overdue, -> { where('due_date < ?', Time.current) }
  scope :due_soon, -> { where(due_date: Time.current..1.week.from_now) }

  # Background job for sending notifications
  after_create :schedule_due_date_reminder
  after_update :handle_status_change

  # Clear project cache when task status changes
  after_save :clear_project_cache
  after_destroy :clear_project_cache

  private

  def schedule_due_date_reminder
    return unless due_date.present?

    DueDateReminderJob.set(wait_until: due_date - 1.day).perform_later(self)
  end

  def handle_status_change
    if saved_change_to_status? && completed?
      TaskCompletionJob.perform_later(self)
    end
  end

  # Clear cache for all associated projects when task changes
  def clear_project_cache
    projects.each(&:clear_cache!)
  end
end