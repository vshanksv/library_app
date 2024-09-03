module TokenService
  class Create
    include BaseService

    attr_reader :api_key

    def initialize(api_key)
      @api_key = api_key
    end

    def call
      return failure({ error_message: "Invalid API Key", error_type: "invalid_api_key" }) if user_api_key.blank?

      success({
        access_token: access_token,
        refresh_token: refresh_token,
        expires_in: 1.day.from_now.to_i,
        refresh_expires_in: 1.week.from_now.to_i
      })
    end

    private

    def user_api_key
      @user_api_key ||= User.find_by(api_key: api_key)
    end

    def access_token
      @access_token ||= JwtHelper.encode({ user_id: user_api_key.id })
    end

    def refresh_token
      @refresh_token ||= JwtHelper.encode({ user_id: user_api_key.id }, 1.week.from_now.to_i)
    end
  end
end
