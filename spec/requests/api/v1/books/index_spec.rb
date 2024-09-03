require 'rails_helper'

RSpec.describe Api::V1::BooksController, type: :request do
  let(:user) { create(:user, :admin) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:token) { JwtHelper.encode(user_id: user.id) }

  describe 'GET /api/v1/books' do
    context 'when the user is authorized' do
      context 'when there are books' do
        before { create_list(:book, 25) }

        it 'returns a paginated list of books' do
          get '/api/v1/books', headers: headers

          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['books'].size).to eq(20)
          expect(json_response['meta']['current_page']).to eq(1)
          expect(json_response['meta']['total_pages']).to eq(2)
          expect(json_response['meta']['total_count']).to eq(25)
        end

        it 'returns the second page when requested' do
          get '/api/v1/books?page=2', headers: headers

          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['books'].size).to eq(5)
          expect(json_response['meta']['current_page']).to eq(2)
        end

        it 'caches the response' do
          expect(Rails.cache).to receive(:fetch).at_least(:once).and_call_original

          get '/api/v1/books', headers: headers
          expect(response).to have_http_status(:ok)

          # Second request should hit the cache
          get '/api/v1/books', headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when there are no books' do
        it 'returns an empty list' do
          get '/api/v1/books', headers: headers

          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)
          expect(json_response['books']).to be_empty
          expect(json_response['meta']['total_count']).to eq(0)
        end
      end
    end

    context 'when the user is not authorized' do
      let(:headers) { {} }

      it 'returns an unauthorized error' do
        get '/api/v1/books', headers: headers

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)).to eq('error_message' => 'Access token is not found or invalid', 'error_type' => 'invalid_token')
      end
    end
  end
end
