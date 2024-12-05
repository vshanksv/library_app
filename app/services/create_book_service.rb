class CreateBookService
  include BaseService

  attr_reader :isbn, :title, :author

  def initialize(isbn:, title:, author:)
    @isbn = isbn
    @title = title
    @author = author
  end

  def call
    book = Book.new(isbn: isbn, title: title, author: author)

    if book.save
      success(book)
    else
      Rails.logger.error(book.errors.full_messages.join(", "))
      failure(book.errors.full_messages.join(", "))
    end
  end
end
