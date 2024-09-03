module Api
  module V1
    class BooksController < ApplicationController
      before_action :authorize_user!

      def create
        result = CreateBookService.call(isbn: params[:isbn], title: params[:title], author: params[:author])

        if result.success?
          @book = result.response
          clear_all_book_caches
          render status: :created
        else
          render json: { error_message: result.response, error_type: 'invalid_book' }, status: :unprocessable_entity
        end
      end

      def index
        cache_key = "books_page_#{params[:page] || 1}"
        @result = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
          books = Book.page(params[:page]).per(10)
          {
            books: books.map(&:attributes),
            current_page: books.current_page,
            total_pages: books.total_pages,
            total_count: books.total_count
          }
        end
      end

      private

      def clear_all_book_caches
        Rails.cache.delete_matched("books_page_*")
      end
    end
  end
end
