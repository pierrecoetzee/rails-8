# Create a default admin user for development
unless Rails.env.production?
  email_address = "admin@example.com"
  user = User.find_or_create_by(email_address: email_address) do |user|
    user.name = "Admin User"
    user.password = "rails123"
  end

  puts "Created admin user: #{email_address} / rails123"

  project = Project.create!(
    name: "Default Project 1",
    description: "Default Project",
    user: user
  )

  # Create tasks and associate them with the project
  task1 = Task.create!(
    title: "Default Task 1",
    description: "Default Task desc",
    status: :pending,
    priority: :low,
    user: user
  )
  project.tasks << task1

  task2 = Task.create!(
    title: "Default Task 2",
    description: "Default Task desc",
    status: :in_progress,
    priority: :medium,
    user: user
  )
  project.tasks << task2

  task3 = Task.create!(
    title: "Default Task 3",
    description: "Default Task desc",
    status: :completed,
    priority: :high,
    user: user
  )
  project.tasks << task3

  puts "Created project '#{project.name}' with #{project.tasks.count} tasks"
end