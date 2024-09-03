require 'rails_helper'

RSpec.describe CreateBorrowerService do
  let(:name) { "John Doe" }
  let(:email) { "john.doe@example.com" }

  subject { described_class.new(name: name, email: email) }

  describe "#call" do
    context "when valid parameters are provided" do
      it "creates a new borrower user" do
        result = subject.call
        expect(result.success?).to be true
        expect(result.response).to be_a(User)
        expect(result.response.role).to eq("borrower")
      end
    end

    context "when name is missing" do
      let(:name) { nil }

      it "fails to create a borrower user" do
        result = subject.call
        expect(result.success?).to be false
        expect(result.response).to include("Name can't be blank")
      end
    end

    context "when email is missing" do
      let(:email) { nil }

      it "fails to create a borrower user" do
        result = subject.call
        expect(result.success?).to be false
        expect(result.response).to include("Email can't be blank")
      end
    end

    context "when email is invalid" do
      let(:email) { "invalid_email" }

      it "fails to create a borrower user" do
        result = subject.call
        expect(result.success?).to be false
        expect(result.response).to include("Email is invalid")
      end
    end

    context "when email is not unique" do
      before { create(:user, email: email) }

      it "fails to create a borrower user" do
        result = subject.call
        expect(result.success?).to be false
        expect(result.response).to include("Email has already been taken")
      end
    end
  end
end
