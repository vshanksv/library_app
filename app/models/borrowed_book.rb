class BorrowedBook < ApplicationRecord
  belongs_to :book
  belongs_to :user

  enum status: { borrowed: 0, returned: 1 }
end
