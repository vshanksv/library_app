require 'rails_helper'

RSpec.describe CreateBookService do
  let(:isbn) { '1234567890' }
  let(:title) { 'Test Book' }
  let(:author) { 'Test Author' }
  let(:service) { described_class.new(isbn: isbn, title: title, author: author) }

  describe '#call' do
    context 'when the book is successfully created' do
      it 'returns success with the book' do
        result = service.call

        expect(result.success?).to be true
        expect(result.response).to be_a(Book)
        expect(result.response.isbn).to eq(isbn)
        expect(result.response.title).to eq(title)
        expect(result.response.author).to eq(author)
      end
    end

    context 'when the book creation fails' do
      before do
        allow_any_instance_of(Book).to receive(:save).and_return(false)
        allow_any_instance_of(Book).to receive_message_chain(:errors, :full_messages).and_return(['Error message'])
      end

      it 'returns failure with error messages' do
        result = service.call

        expect(result.success?).to be false
        expect(result.response).to eq('Error message')
      end
    end

    context 'when isbn is missing' do
      let(:isbn) { nil }

      it 'returns failure with error messages' do
        result = service.call

        expect(result.success?).to be false
        expect(result.response).to include("Isbn can't be blank")
      end
    end

    context 'when title is missing' do
      let(:title) { nil }

      it 'returns failure with error messages' do
        result = service.call

        expect(result.success?).to be false
        expect(result.response).to include("Title can't be blank")
      end
    end

    context 'when author is missing' do
      let(:author) { nil }

      it 'returns failure with error messages' do
        result = service.call

        expect(result.success?).to be false
        expect(result.response).to include("Author can't be blank")
      end
    end

    context 'when isbn format is invalid' do
      let(:isbn) { 'invalid_isbn' }

      it 'returns failure with error messages' do
        result = service.call

        expect(result.success?).to be false
        expect(result.response).to include("Isbn is invalid")
      end
    end

    context 'when isbn is a duplicate' do
      before { create(:book, isbn: isbn, title: "random", author: author) }

      it 'returns failure with error messages' do
        result = service.call

        expect(result.success?).to be false
        expect(result.response).to include("Title and Author must match the existing record with the same ISBN")
      end
    end
  end
end
