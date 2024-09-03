require 'rails_helper'

RSpec.describe ReturnBookService, type: :service do
  let(:user) { create(:user, email: 'user@example.com') }
  let(:book) { create(:book) }
  let!(:borrowed_book) { create(:borrowed_book, user: user, book: book) }

  subject { described_class.new(email: email, book_id: book_id) }

  describe '#call' do
    let(:email) { user.email }
    let(:book_id) { book.id }

    context 'when user is not found' do
      let(:email) { 'nonexistent@example.com' }

      it 'returns failure with user not found error' do
        result = subject.call

        expect(result.success?).to be_falsey
        expect(result.response[:error_message]).to eq('User not found')
        expect(result.response[:error_type]).to eq('user_not_found')
      end
    end

    context 'when book is not found' do
      let(:book_id) { -1 }

      it 'returns failure with book not found error' do
        result = subject.call

        expect(result.success?).to be_falsey
        expect(result.response[:error_message]).to eq('Book not found')
        expect(result.response[:error_type]).to eq('book_not_found')
      end
    end

    context 'when book is not borrowed by the user' do
      let(:email) { 'other@example.com' }
      let!(:other_user) { create(:user, email: email) }

      it 'returns failure with book not borrowed error' do
        result = subject.call

        expect(result.success?).to be_falsey
        expect(result.response[:error_message]).to eq("Could not return a book that's not borrowed")
        expect(result.response[:error_type]).to eq('book_not_borrowed')
      end
    end

    context 'when book is successfully returned' do
      it 'returns success and updates the book status to returned' do
        result = subject.call

        expect(result.success?).to be_truthy
        expect(result.response).to eq(book)
        expect(borrowed_book.reload.status).to eq('returned')
      end
    end

    context 'when book return fails' do
      it 'returns failure with validation error' do
        allow_any_instance_of(BorrowedBook).to receive(:update).and_return(false)
        allow_any_instance_of(BorrowedBook).to receive_message_chain(:errors, :full_messages).and_return(['Some error'])

        result = subject.call

        expect(result.success?).to be_falsey
        expect(result.response).to eq('Some error')
      end
    end
  end
end
