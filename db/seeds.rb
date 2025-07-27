# Create a default admin user for development
unless Rails.env.production?
  email_address = "admin@example.com"
  User.find_or_create_by(email_address: email_address) do |user|
    user.name = "Admin User"
    user.password = "rails123"
  end

  puts "Created admin user: #{email_address} / rails123"
end