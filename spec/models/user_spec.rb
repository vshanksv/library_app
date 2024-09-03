require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { User.new(name: 'Test User', email: 'test@example.com') }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is not valid without a name' do
      user.name = nil
      expect(user).to_not be_valid
    end

    it 'is not valid without an email' do
      user.email = nil
      expect(user).to_not be_valid
    end

    it 'is not valid with a duplicate email' do
      User.create!(name: 'Existing User', email: 'test@example.com')
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'is not valid with an invalid email format' do
      user.email = 'invalid_email'
      expect(user).to_not be_valid
      expect(user.errors[:email]).to include('is invalid')
    end
  end

  describe 'custom validations' do
    it 'normalizes the email before validation' do
      user.email = ' TEST@EXAMPLE.COM '
      user.valid?
      expect(user.email).to eq('test@example.com')
    end
  end

  describe 'associations' do
    it 'has many borrowed_books' do
      assoc = User.reflect_on_association(:borrowed_books)
      expect(assoc.macro).to eq :has_many
    end
  end
end
