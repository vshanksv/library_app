require 'rails_helper'

RSpec.describe BorrowedBook, type: :model do
  let(:book) { Book.create(isbn: '1234567890', title: 'Test Book', author: 'Test Author') }
  let(:user) { User.create(name: 'Test User', email: 'test@example.com') }
  let(:borrowed_book) { BorrowedBook.create(book: book, user: user, status: :borrowed) }

  describe 'associations' do
    it 'belongs to a book' do
      expect(borrowed_book.book).to eq(book)
    end

    it 'belongs to a user' do
      expect(borrowed_book.user).to eq(user)
    end
  end

  describe 'enums' do
    it 'can have a status of borrowed' do
      borrowed_book.status = :borrowed
      expect(borrowed_book).to be_borrowed
    end

    it 'can have a status of returned' do
      borrowed_book.status = :returned
      expect(borrowed_book).to be_returned
    end
  end
end
