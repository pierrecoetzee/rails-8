
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy, :new_project_task]

  def index
    @projects = Current.user.projects.includes(:tasks).order(created_at: :desc)

    # Preload the task statistics for all projects to avoid N+1 queries
    @project_stats = {}
    @projects.each do |project|
      @project_stats[project.id] = {
        task_completion_percentage: project.task_completion_percentage,
        tasks_count: project.tasks_count,
        completed_tasks_count: project.completed_tasks_count,
        pending_tasks_count: project.pending_tasks_count
      }
    end
  end

  def show
    @tasks = @project.tasks.includes(:user).order(created_at: :desc)
    @new_task = @project.tasks.build
  end

  def new
    @project = Current.user.projects.build
  end

  def create
    @project = Current.user.projects.build(project_params)

    if @project.save
      # Clear the user stats cache
      Rails.cache.delete("user_#{Current.user.id}_stats")

      broadcast_project_stats

      redirect_to projects_path, notice: "Project was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    project_name = @project.name
    @project.destroy if @project

    # Clear the user stats cache
    Rails.cache.delete("user_#{Current.user.id}_stats")

    broadcast_project_stats

    redirect_to projects_path, notice: "Project: #{project_name}, was successfully deleted."
  end

  def new_project_task
    @task = Task.new
    @task.projects = [@project]
  end

  private

  def broadcast_project_stats
    stats = fresh_user_stats

    # Broadcast the stats update via Action Cable
    ActionCable.server.broadcast(
      "user_#{Current.user.id}_stats",
      {
        type: 'projects_stats_update',
        html: ApplicationController.render(
          partial: 'dashboard/projects_stats_broadcast',
          locals: {
            total_projects: stats[:total_projects]
          }
        )
      }
    )
  end

  def set_project
    @project = Current.user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end

  def fresh_user_stats
    {
      total_tasks: Current.user.tasks.count,
      completed_tasks: Current.user.tasks.completed.count,
      pending_tasks: Current.user.tasks.pending.count,
      total_projects: Current.user.projects.count
    }
  end
end