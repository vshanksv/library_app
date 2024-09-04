class AddPartialIndexToUsersApiKey < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :api_key, where: "api_key IS NOT NULL", unique: true
  end
end
