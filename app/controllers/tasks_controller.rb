class TasksController < ApplicationController
  before_action :require_authentication
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :set_project, only: [:edit, :index, :new, :create], if: -> { params[:project_id].present? }

  def index
    if @project
      # When viewing tasks for a specific project
      @tasks = Rails.cache.fetch("project_#{@project.id}_tasks_#{params[:status]}", expires_in: 10.minutes) do
        tasks = @project.tasks.includes(:user, :projects).order(created_at: :desc)
        tasks = tasks.where(status: params[:status]) if params[:status].present?
        tasks.to_a
      end

      @task_counts = {
        all: @project.tasks.count,
        pending: @project.tasks.pending.count,
        in_progress: @project.tasks.in_progress.count,
        completed: @project.tasks.completed.count
      }
    else
      # When viewing all user tasks (existing logic)
      @tasks = Rails.cache.fetch("user_#{Current.user.id}_tasks_#{params[:status]}", expires_in: 10.minutes) do
        tasks = Current.user.tasks.includes(:projects).order(created_at: :desc)
        tasks = tasks.where(status: params[:status]) if params[:status].present?
        tasks.to_a
      end

      @task_counts = {
        all: Current.user.tasks.count,
        pending: Current.user.tasks.pending.count,
        in_progress: Current.user.tasks.in_progress.count,
        completed: Current.user.tasks.completed.count
      }
    end
  end

  def show
  end

  def new
    if @project
      # Creating a task for a specific project
      @task = Task.new
      @task.projects = [@project]
    else
      # Creating a standalone task
      @task = Current.user.tasks.build
    end
  end

  def create
    @task = Current.user.tasks.build(task_params)

    # If creating for a specific project, associate it
    if @project
      @task.projects = [@project]
    end

    if @task.save
      # Clear cached tasks and project stats
      clear_user_task_caches
      @project&.clear_cache!

      redirect_path = @project ? project_path(@project) : tasks_path
      redirect_to redirect_path, notice: "Task created successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    # Clear caches before update
    # @task.projects.each do |project|
    #   Rails.cache.delete("project_#{project.id}_tasks_#{params[:status]}")
    # end
    clear_user_task_caches

    if @task.update(task_params)
      # Clear cache for all associated projects
      @task.projects.each(&:clear_cache!)

      # Redirect to project tasks index if task belongs to a project
      if @task.projects.any?
        redirect_to project_tasks_path(@task.projects.first), notice: "Task updated successfully!"
      else
        redirect_to @task, notice: "Task updated successfully!"
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    clear_user_task_caches
    redirect_to tasks_path, notice: "Task deleted successfully!"
  end

  private

  def set_task
    @task = Current.user.tasks.find(params[:id])
  end

  def set_project
    @project = Current.user.projects.find(params[:project_id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :status, :priority, :due_date, project_ids: [])
  end

  def clear_user_task_caches
    # SolidCache doesn't support delete_matched, so we clear specific keys
    user_id = Current.user.id

    # Clear all possible status-based task caches
    ["", "all", "pending", "in_progress", "completed", "cancelled"].each do |status|
      Rails.cache.delete("user_#{user_id}_tasks_#{status}")
    end

    # Clear other user-specific caches

    Rails.cache.delete("user_#{user_id}_recent_tasks")
    Rails.cache.delete("user_#{user_id}_stats")
  end
end
