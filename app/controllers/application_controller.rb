class ApplicationController < ActionController::Base
  include Authenticated
  skip_before_action :verify_authenticity_token

  rescue_from ApiExceptions::BaseError, with: :handle_error_exception
  rescue_from ActiveRecord::RecordNotFound, with: :handle_active_record_exception

  def handle_error_exception(exception)
    render json: exception.to_h, status: exception.code
  end

  def handle_active_record_exception(exception)
    render json: { message: "Not Found", detail: exception.message, status_code: 404 }, status: :not_found
  end

  def validate_params!(schema)
    result = schema.call(params.to_unsafe_hash)

    unless result.success?
      raise ApiExceptions::RequestParamError.new(
        message: 'Invalid HTTP parameters.',
        detail: result.errors.to_h
      )
    end

    result.to_h
  end
end
