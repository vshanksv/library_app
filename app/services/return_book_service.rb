class ReturnBookService
  include BaseService

  def initialize(email:, book_id:)
    @user = User.find_by(email: email)
    @book = Book.find_by(id: book_id)
  end

  def call
    return failure(user_not_found_error) unless @user
    return failure(book_not_found_error) unless @book

    borrowed_book = BorrowedBook.where(user: @user, book: @book, status: :borrowed).last
    return failure(book_not_borrowed_error) unless borrowed_book

    if borrowed_book.update(status: :returned)
      success(@book)
    else
      failure(borrowed_book.errors.full_messages.to_sentence)
    end
  end

  private

  def user_not_found_error
    { error_message: 'User not found', error_type: 'user_not_found' }
  end

  def book_not_found_error
    { error_message: 'Book not found', error_type: 'book_not_found' }
  end

  def book_not_borrowed_error
    { error_message: "Could not return a book that's not borrowed", error_type: 'book_not_borrowed' }
  end
end
