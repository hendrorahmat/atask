module ApiExceptions
  class RequestParamError < ApiExceptions::BaseError
    def initialize(message: nil, detail: nil, code: 500)
      @code = 422

      super
    end
  end
end
