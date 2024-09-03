module TokenService
  class Refresh
    include BaseService

    attr_reader :refresh_token

    def initialize(refresh_token)
      @refresh_token = refresh_token
    end

    def call
      payload = decode_refresh_token
      return payload if payload.is_a?(ServiceResult) && !payload.success?

      user = find_user(payload["user_id"])
      return user if user.is_a?(ServiceResult) && !user.success?

      access_token = JwtHelper.encode({ user_id: user.id })
      success({ access_token: })
    end

    private

    def decode_refresh_token
      JwtHelper.decode(refresh_token).first
    rescue JWT::ExpiredSignature => e
      handle_error(e.message, "refresh_token_expired")
    rescue StandardError => e
      handle_error('Invalid refresh token', "invalid_refresh_token")
    end

    def find_user(user_id)
      user = User.find_by(id: user_id)
      return user if user.present?

      handle_error("Invalid refresh token", "invalid_refresh_token")
    end

    def handle_error(message, error_type)
      Rails.logger.error "#{error_type}: #{message}"
      failure({ error_message: message, error_type: error_type })
    end
  end
end
