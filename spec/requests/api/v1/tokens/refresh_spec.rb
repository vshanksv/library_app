require 'rails_helper'

RSpec.describe Api::V1::TokensController, type: :request do
  let(:user) { create(:user, :admin) }
  let(:valid_refresh_token) { JwtHelper.encode({ user_id: user.id }) }
  let(:expired_refresh_token) { JwtHelper.encode({ user_id: user.id }, 1.hour.ago.to_i) }
  let(:invalid_refresh_token) { 'invalid.token.here' }

  describe 'POST /api/v1/tokens/refresh' do
    context 'with valid refresh token' do
      it 'returns a new access token' do
        post '/api/v1/tokens/refresh', params: { refresh_token: valid_refresh_token }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key('access_token')
      end
    end

    context 'with invalid refresh token' do
      it 'returns unauthorized' do
        post '/api/v1/tokens/refresh', params: { refresh_token: invalid_refresh_token }

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)).to have_key('error_message')
      end
    end

    context 'with expired refresh token' do
      it 'returns unauthorized' do
        post '/api/v1/tokens/refresh', params: { refresh_token: expired_refresh_token }

        expect(response).to have_http_status(422)
        expect(JSON.parse(response.body)).to have_key('error_message')
      end
    end
  end
end
