namespace :one_off do
  desc "Create admin user"
  task create_admin_user: :environment do
    User.create!(
      name: 'Admin',
      email: 'admin@example.com',
      role: 'admin',
      api_key: SecureRandom.hex(20)
    )
  end

  desc "Retrieve admin user api key"
  task retrieve_admin_user_api_key: :environment do
    admin = User.admin.first
    puts "Admin user API key: #{admin.api_key}"
  end
end