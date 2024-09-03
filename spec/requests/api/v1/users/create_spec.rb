require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:non_admin_user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:token) { JwtHelper.encode(user_id: admin_user.id) }
  let(:invalid_token) { 'invalid_token' }

  def json
    JSON.parse(response.body)
  end

  describe 'POST /api/v1/users' do
    context 'when the request is valid' do
      before do
        allow(CreateBorrowerService).to receive(:call).and_return(double(success?: true, response: non_admin_user))
        post '/api/v1/users', params: { name: non_admin_user.name, email: non_admin_user.email }, headers: headers
      end

      it 'creates a user' do
        expect(response).to have_http_status(:created)
        expect(json['id']).to eq(non_admin_user.id)
        expect(json['name']).to eq(non_admin_user.name)
        expect(json['email']).to eq(non_admin_user.email)
      end
    end

    context 'when the token is missing or invalid' do
      before { post '/api/v1/users', params: { name: 'John Doe', email: 'john@example.com' }, headers: { 'Authorization' => "Bearer #{invalid_token}" } }

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
        expect(json['error_message']).to eq('Access token is not found or invalid')
      end
    end

    context 'when the user is not an admin' do
      let(:token) { JwtHelper.encode(user_id: non_admin_user.id) }

      before { post '/api/v1/users', params: { name: 'John Doe', email: 'john@example.com' }, headers: headers }

      it 'returns unauthorized status' do
        expect(response).to have_http_status(:unauthorized)
        expect(json['error_message']).to eq('Admin user is not found')
      end
    end

    context 'when the borrower creation is invalid' do
      before do
        allow(CreateBorrowerService).to receive(:call).and_return(double(success?: false, response: 'Invalid borrower'))
        post '/api/v1/users', params: { name: 'John Doe', email: 'john@example.com' }, headers: headers
      end

      it 'returns unprocessable entity status' do
        expect(response).to have_http_status(422)
        expect(json['error_message']).to eq('Invalid borrower')
      end
    end
  end
end
