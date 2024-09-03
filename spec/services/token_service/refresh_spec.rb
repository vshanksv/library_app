require 'rails_helper'

RSpec.describe TokenService::Refresh, type: :service do
  let(:user) { create(:user) }
  let(:refresh_token) { JwtHelper.encode({ user_id: user.id }, 1.day.from_now.to_i) }
  let(:expired_refresh_token) { JwtHelper.encode({ user_id: user.id }, 1.day.ago.to_i) }
  let(:invalid_refresh_token) { 'invalid.token.here' }

  describe '#call' do
    context 'with a valid refresh token' do
      it 'returns a new access token' do
        result = described_class.call(refresh_token)
        expect(result.success?).to be true
        expect(result.response[:access_token]).to be_present
      end
    end

    context 'with an expired refresh token' do
      it 'returns an error' do
        result = described_class.call(expired_refresh_token)
        expect(result.success?).to be false
        expect(result.response[:error_message]).to eq('Signature has expired')
        expect(result.response[:error_type]).to eq('refresh_token_expired')
      end
    end

    context 'with an invalid refresh token' do
      it 'returns an error' do
        result = described_class.call(invalid_refresh_token)
        expect(result.success?).to be false
        expect(result.response[:error_message]).to eq('Invalid refresh token')
        expect(result.response[:error_type]).to eq('invalid_refresh_token')
      end
    end

    context 'when user is not found' do
      let(:non_existent_user_token) { JwtHelper.encode({ user_id: 0 }, 1.day.from_now.to_i) }

      it 'returns an error' do
        result = described_class.call(non_existent_user_token)
        expect(result.success?).to be false
        expect(result.response[:error_message]).to eq('Invalid refresh token')
        expect(result.response[:error_type]).to eq('invalid_refresh_token')
      end
    end
  end
end
