class CreateBorrowedBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :borrowed_books do |t|
      t.bigint :user_id
      t.bigint :book_id
      t.integer :status

      t.timestamps
    end
  end
end
