require 'rails_helper'

RSpec.describe "Api::V1::Tokens", type: :request do
  describe "POST /api/v1/tokens" do
    let(:valid_api_key) { "valid_api_key" }
    let(:invalid_api_key) { "invalid_api_key" }
    let!(:user) { create(:user, api_key: valid_api_key) }

    context "with valid api_key" do
      it "returns access and refresh tokens" do
        post "/api/v1/tokens", params: { api_key: valid_api_key }

        expect(response).to have_http_status(:created)
        expect(json_response).to include(
          "access_token",
          "refresh_token",
          "expires_in",
          "refresh_expires_in"
        )
      end
    end

    context "with invalid api_key" do
      it "returns an unauthorized error" do
        post "/api/v1/tokens", params: { api_key: invalid_api_key }

        expect(response).to have_http_status(422)
        expect(json_response).to include(
          "error_message" => "Invalid API Key",
          "error_type" => "invalid_api_key"
        )
      end
    end
  end

  def json_response
    JSON.parse(response.body)
  end
end
