# frozen_string_literal: true

class ApiExceptions::UnauthorizedError < ApiExceptions::BaseError
  def initialize(message: "User not authorized!", detail: "Unauthorized", code: 401)
    super
  end
end
