module BaseService
  extend ActiveSupport::Concern

  class_methods do
    def call(...)
      new(...).call
    end
  end

  def failure(error)
    ServiceResult.new(success: false, response: error)
  end

  def success(args = {})
    ServiceResult.new(success: true, response: args)
  end

  class ServiceResult < OpenStruct
    def initialize(success:, response:)
      super(success?: success, response:)
    end
  end
end
