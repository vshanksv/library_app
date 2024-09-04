class AddIndexToBorrowedBooks < ActiveRecord::Migration[7.1]
  def change
    add_index :borrowed_books, [:book_id, :status, :user_id]
  end
end
