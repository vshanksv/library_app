require 'rails_helper'

RSpec.describe BorrowBookService, type: :service do
  let(:user) { create(:user) }
  let(:book) { create(:book) }
  let(:service) { described_class.new(email: user.email, book_id: book.id) }

  describe '#call' do
    context 'when user is not found' do
      let(:service) { described_class.new(email: 'nonexistent@example.com', book_id: book.id) }

      it 'returns failure with user not found error' do
        result = service.call
        expect(result.success?).to be false
        expect(result.response[:error_message]).to eq('User not found')
        expect(result.response[:error_type]).to eq('user_not_found')
      end
    end

    context 'when book is not found' do
      let(:service) { described_class.new(email: user.email, book_id: -1) }

      it 'returns failure with book not found error' do
        result = service.call
        expect(result.success?).to be false
        expect(result.response[:error_message]).to eq('Book not found')
        expect(result.response[:error_type]).to eq('book_not_found')
      end
    end

    context 'when book is already borrowed' do
      before do
        create(:borrowed_book, book: book, user: user, status: :borrowed)
      end

      it 'returns failure with book already borrowed error' do
        result = service.call
        expect(result.success?).to be false
        expect(result.response[:error_message]).to eq('Book already borrowed')
        expect(result.response[:error_type]).to eq('book_already_borrowed')
      end
    end

    context 'when book is successfully borrowed' do
      it 'returns success with the book' do
        result = service.call
        expect(result.success?).to be true
        expect(result.response).to eq(book)
      end
    end

    context 'when borrowed book fails to save' do
      before do
        allow_any_instance_of(BorrowedBook).to receive(:save).and_return(false)
        allow_any_instance_of(BorrowedBook).to receive_message_chain(:errors, :full_messages).and_return(['Some error'])
      end

      it 'returns failure with error messages' do
        result = service.call
        expect(result.success?).to be false
        expect(result.response).to eq('Some error')
      end
    end
  end
end
