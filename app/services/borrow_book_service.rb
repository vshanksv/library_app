class BorrowBookService
  include BaseService

  attr_reader :email, :book_id

  def initialize(email:, book_id:)
    @user = find_user(email)
    @book = find_book(book_id)
  end

  def call
    return handle_failure("User not found", "user_not_found") if @user.blank?
    return handle_failure("Book not found", "book_not_found") if @book.blank?
    return handle_failure("Book already borrowed", "book_already_borrowed") if @book.borrowed_books.borrowed.present?

    borrowed_book = BorrowedBook.new(user: @user, book: @book, status: :borrowed)
    if borrowed_book.save
      success(@book)
    else
      failure(borrowed_book.errors.full_messages.join(", "))
    end
  end

  private

  def find_user(email)
    User.find_by(email: email)
  end

  def find_book(book_id)
    Book.find_by(id: book_id)
  end

  def handle_failure(error_message, error_type)
    failure({ error_message: error_message, error_type: error_type })
  end
end
