module Api
  module V1
    class TokensController < ApplicationController
      def create
        result = TokenService::Create.call(params[:api_key])

        if result.success?
          render json: result.response, status: :created
        else
          render json: result.response, status: :unprocessable_entity
        end
      end

      def refresh
        result = TokenService::Refresh.call(params[:refresh_token])

        if result.success?
          render json: result.response, status: :created
        else
          render json: result.response, status: :unprocessable_entity
        end
      end
    end
  end
end
