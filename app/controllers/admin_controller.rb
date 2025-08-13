class AdminController < ApplicationController
  def index
    @total_users = User.count
    @total_tasks = Task.count
    @total_projects = Project.count
    @cache_stats = cache_statistics
  end

  def users
    @users = User.includes(:tasks, :projects).order(created_at: :desc)
  end

  def tasks
    @tasks = Task.includes(:user, :projects).order(created_at: :desc)
  end

  def cache_stats
    load_cache_data
  end

  def refresh_cache_stats
    load_cache_data

    respond_to do |format|
      format.html  # This will render refresh_cache_stats.html.erb
      format.turbo_stream  # This will render refresh_cache_stats.turbo_stream.erb
    end
  end

  def clear_cache

    # Clear all project-related cache
    Project.find_each do |project|
      project.clear_cache!
    end

    # Clear other application cache if needed
    Rails.cache.clear

    respond_to do |format|
      format.html { redirect_to admin_refresh_cache_stats_path, notice: 'Cache cleared successfully!' }
      format.turbo_stream do
        load_cache_data
        render turbo_stream: turbo_stream.replace("project_cache_status", partial: "project_cache_table")
      end
    end
  end

  def clear_project_cache
    project = Project.find(params[:project_id])
    project.clear_cache!

    respond_to do |format|
      format.html { redirect_to admin_cache_stats_path, notice: "Cache cleared for project: #{project.name}" }
      format.turbo_stream do
        load_cache_data
        render turbo_stream: turbo_stream.replace("project_cache_status", partial: "project_cache_table")
      end
    end
  end

  private

  def load_cache_data
    @cache_stats = cache_statistics
    @cached_projects = Project.all.map do |project|
      {
        project: project,
        cached_completion: Rails.cache.exist?("project_#{project.id}_completion"),
        cached_tasks_count: Rails.cache.exist?("project_#{project.id}_tasks_count"),
        cached_completed_count: Rails.cache.exist?("project_#{project.id}_completed_tasks_count")
      }
    end
  end

  def cache_statistics
    # This will depend on your Solid Cache setup
    # You might want to implement custom cache stats
    {
      total_entries: "N/A", # Solid Cache doesn't expose this easily
      memory_usage: "N/A",
      hit_rate: "N/A"
    }
  end
end