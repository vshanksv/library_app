require 'rails_helper'

RSpec.describe Api::V1::BooksController, type: :request do
  let(:user) { create(:user, :admin) }
  let(:headers) { { "Authorization" => "Bearer #{JwtHelper.encode(user_id: user.id)}" } }

  describe "POST /api/v1/books" do
    context "with valid parameters" do
      let(:valid_params) { { isbn: "1234567890", title: "Sample Book", author: "John Doe" } }

      it "creates a new book" do
        expect {
          post "/api/v1/books", params: valid_params, headers: headers
        }.to change(Book, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { isbn: "", title: "", author: "" } }

      it "does not create a new book" do
        expect {
          post "/api/v1/books", params: invalid_params, headers: headers
        }.not_to change(Book, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
