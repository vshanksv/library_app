module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorize_user!

      def create
        result = CreateBorrowerService.call(name: params[:name], email: params[:email])
        
        if result.success?
          @user = result.response
          render status: :created
        else
          render json: { error_message: result.response, error_type: 'invalid_borrower' }, status: :unprocessable_entity
        end
      end
    end
  end
end
