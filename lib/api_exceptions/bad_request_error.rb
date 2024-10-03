# frozen_string_literal: true

class ApiExceptions::BadRequestError < ApiExceptions::BaseError
  def initialize(message: "Invalid Data", detail: nil, code: 400)
    super
  end
end
