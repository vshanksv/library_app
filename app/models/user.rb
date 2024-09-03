class User < ApplicationRecord
  enum role: { admin: 0, borrower: 1 }

  validates :name, presence: true
  validates :email, presence: true, db_uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  normalizes :email, with: ->(email) { email.strip.downcase }

  has_many :borrowed_books, dependent: :destroy
end
