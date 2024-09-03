module JwtHelper
  def self.encode(payload, exp = 1.day.from_now.to_i)
    payload[:exp] = exp
    JWT.encode(payload, ENV.fetch('HMAC_SECRET'), 'HS256', { typ: 'JWT' })
  end

  def self.decode(token)
    JWT.decode(token, ENV.fetch('HMAC_SECRET'), true, { algorithm: 'HS256' })
  end
end
