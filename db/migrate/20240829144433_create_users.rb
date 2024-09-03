class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email, index: { unique: true }
      t.integer :role, default: 1
      t.string :api_key

      t.timestamps
    end
  end
end
