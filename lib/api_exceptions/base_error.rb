module ApiExceptions
  class BaseError < ::StandardError
    attr_accessor :message, :detail, :code, :send_to_sentry

    def initialize(message: nil, detail: nil, code: 500)
      @message = message || "Something went wrong"
      @detail = detail || "Something went wrong"
      @code ||= code
    end

    def to_h
      {
        message: message,
        detail: detail,
        status_code: code
      }.compact
    end
  end
end
