class CreateBorrowerService
  include BaseService

  attr_reader :name, :email

  def initialize(name:, email:)
    @name = name
    @email = email
  end

  def call
    user = User.new(name: name, email: email, role: :borrower)

    if user.save
      success(user)
    else
      Rails.logger.error(user.errors.full_messages.join(", "))
      failure(user.errors.full_messages.join(", "))
    end
  end
end
