class Book < ApplicationRecord
  validates :isbn, :title, :author, presence: true
  validates :isbn, format: { with: /\A(?:\d{9}X|\d{10}|\d{13})\z/, message: "is invalid" }
  validate :title_and_author_consistency

  before_validation :normalize_isbn

  has_many :borrowed_books

  private

  def title_and_author_consistency
    existing_book = Book.where(isbn: isbn).where.not(id: id).first
    if existing_book && (existing_book.title != title || existing_book.author != author)
      errors.add(:base, "Title and Author must match the existing record with the same ISBN")
    end
  end

  def normalize_isbn
    self.isbn = isbn.to_s.gsub(/[^0-9X]/i, '').upcase if isbn
  end
end