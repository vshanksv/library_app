require 'rails_helper'

RSpec.describe Api::V1::ReturnedBooksController, type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:non_admin_user) { create(:user) }
  let(:book) { create(:book) }
  let!(:borrowed_book) { create(:borrowed_book, user: non_admin_user, book: book) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }
  let(:token) { JwtHelper.encode(user_id: admin_user.id) }

  describe "POST /api/v1/returned_books" do
    context "when the request is valid" do
      before do
        post "/api/v1/returned_books", params: { email: non_admin_user.email, book_id: book.id }, headers: headers
      end

      it "returns status code 200" do
        expect(response).to have_http_status(201)
      end

      it "returns the book with status" do
        expect(json['id']).to eq(book.id)
        expect(json['status']).to eq('success')
      end
    end

    context "when the user is not found" do
      before do
        post "/api/v1/returned_books", params: { email: 'nonexistent@example.com', book_id: book.id }, headers: headers
      end

      it "returns status code 422" do
        expect(response).to have_http_status(422)
      end

      it "returns an error message" do
        expect(json['error_message']).to eq('User not found')
        expect(json['error_type']).to eq('user_not_found')
      end
    end

    context "when the book is not found" do
      before do
        post "/api/v1/returned_books", params: { email: non_admin_user.email, book_id: 0 }, headers: headers
      end

      it "returns status code 422" do
        expect(response).to have_http_status(422)
      end

      it "returns an error message" do
        expect(json['error_message']).to eq('Book not found')
        expect(json['error_type']).to eq('book_not_found')
      end
    end

    context "when the book is not borrowed by the user" do
      before do
        borrowed_book.update(status: :returned)
        post "/api/v1/returned_books", params: { email: non_admin_user.email, book_id: book.id }, headers: headers
      end

      it "returns status code 422" do
        expect(response).to have_http_status(422)
      end

      it "returns an error message" do
        expect(json['error_message']).to eq("Could not return a book that's not borrowed")
        expect(json['error_type']).to eq('book_not_borrowed')
      end
    end
  end
end

def json
  JSON.parse(response.body)
end