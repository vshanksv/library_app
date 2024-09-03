require 'rails_helper'

RSpec.describe Api::V1::BorrowedBooksController, type: :request do
  describe "POST /api/v1/borrowed_books" do
    let(:admin_user) { create(:user, :admin) }
    let(:non_admin_user) { create(:user) }
    let(:book) { create(:book) }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }
    let(:token) { JwtHelper.encode(user_id: admin_user.id) }

    context "when the request is valid" do
      before do
        post "/api/v1/borrowed_books", params: { email: non_admin_user.email, book_id: book.id }, headers: headers
      end

      it "creates a borrowed book" do
        expect(response).to have_http_status(:created)
        expect(json['status']).to eq('success')
        expect(json['id']).to eq(book.id)
      end
    end

    context "when the user is not found" do
      before do
        post "/api/v1/borrowed_books", params: { email: "nonexistent@example.com", book_id: book.id }, headers: headers
      end

      it "returns an error" do
        expect(response).to have_http_status(422)
        expect(json['error_message']).to eq("User not found")
        expect(json['error_type']).to eq("user_not_found")
      end
    end

    context "when the book is not found" do
      before do
        post "/api/v1/borrowed_books", params: { email: non_admin_user.email, book_id: 0 }, headers: headers
      end

      it "returns an error" do
        expect(response).to have_http_status(422)
        expect(json['error_message']).to eq("Book not found")
        expect(json['error_type']).to eq("book_not_found")
      end
    end

    context "when the book is already borrowed" do
      before do
        create(:borrowed_book, book: book, user: non_admin_user)
        post "/api/v1/borrowed_books", params: { email: non_admin_user.email, book_id: book.id }, headers: headers
      end

      it "returns an error" do
        expect(response).to have_http_status(422)
        expect(json['error_message']).to eq("Book already borrowed")
        expect(json['error_type']).to eq("book_already_borrowed")
      end
    end
  end
end

def json
  JSON.parse(response.body)
end
