module Api
  module V1
    class ReturnedBooksController < ApplicationController
      before_action :authorize_user!

      def create
        result = ReturnBookService.call(email: params[:email], book_id: params[:book_id])

        if result.success?
          @book = result.response
          @status = "success"
          render status: :created
        else
          render json: { error_message: result.response[:error_message], error_type: result.response[:error_type] }, status: :unprocessable_entity
        end
      end
    end
  end
end
