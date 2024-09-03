class ApplicationController < ActionController::API
  def current_user
    token = extract_token
    return nil if token.blank?

    user_id = decode_token(token)
    return nil if user_id.blank?

    User.find_by(id: user_id)
  rescue StandardError => e
    Rails.logger.error "Failed to find user. #{e.message}"
    nil
  end

  def authorize_user!
    user = current_user
    if user.nil?
      render json: { error_message: 'Access token is not found or invalid', error_type: 'invalid_token' }, status: :unauthorized
    elsif !user.admin?
      render json: { error_message: 'Admin user is not found', error_type: 'invalid_user' }, status: :unauthorized
    end
  end

  private

  def extract_token
    request.headers['Authorization']&.split&.last
  end

  def decode_token(token)
    JwtHelper.decode(token).first['user_id']
  rescue JWT::DecodeError
    nil
  end
end
