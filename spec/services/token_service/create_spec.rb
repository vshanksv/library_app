require 'rails_helper'

RSpec.describe TokenService::Create, type: :service do
  let(:api_key) { 'valid_api_key' }
  let(:invalid_api_key) { 'invalid_api_key' }
  let!(:user) { create(:user, api_key: api_key) }

  describe '#call' do
    context 'when the API key is valid' do
      it 'returns a success result with tokens' do
        service = described_class.call(api_key)
        expect(service.success?).to be true
        expect(service.response[:access_token]).to be_present
        expect(service.response[:refresh_token]).to be_present
        expect(service.response[:expires_in]).to be_present
        expect(service.response[:refresh_expires_in]).to be_present
      end
    end

    context 'when the API key is invalid' do
      it 'returns a failure result' do
        service = described_class.call(invalid_api_key)
        expect(service.success?).to be false
        expect(service.response[:error_message]).to eq('Invalid API Key')
        expect(service.response[:error_type]).to eq('invalid_api_key')
      end
    end
  end
end
