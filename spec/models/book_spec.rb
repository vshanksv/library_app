require 'rails_helper'

RSpec.describe Book, type: :model do
  let(:book) { Book.new(isbn: '123456789X', title: 'Test Title', author: 'Test Author') }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(book).to be_valid
    end

    it 'is not valid without an isbn' do
      book.isbn = nil
      expect(book).to_not be_valid
    end

    it 'is not valid without a title' do
      book.title = nil
      expect(book).to_not be_valid
    end

    it 'is not valid without an author' do
      book.author = nil
      expect(book).to_not be_valid
    end

    it 'is not valid with an invalid isbn' do
      book.isbn = 'invalid_isbn'
      expect(book).to_not be_valid
    end
  end

  describe 'custom validations' do
    it 'is not valid if title and author do not match existing record with the same isbn' do
      Book.create!(isbn: '123456789X', title: 'Existing Title', author: 'Existing Author')
      book.title = 'Different Title'
      expect(book).to_not be_valid
      expect(book.errors[:base]).to include("Title and Author must match the existing record with the same ISBN")
    end
  end

  describe 'callbacks' do
    it 'normalizes the isbn before validation' do
      book.isbn = ' 123-456-789X '
      book.valid?
      expect(book.isbn).to eq('123456789X')
    end
  end
end
