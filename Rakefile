# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

# Load tasks from app/tasks directory
Dir.glob('app/tasks/**/*.rake').each { |r| load r }
