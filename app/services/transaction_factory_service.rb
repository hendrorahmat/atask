# frozen_string_literal: true

class TransactionFactoryService
  # @return [TransactionInterface]
  def self.make(data)
    case data[:type]
    when CreditService::TYPE_CREDIT
      return CreditService.new
    when DebitService::TYPE_DEBIT
      return DebitService.new
    when TransferService::TYPE_TRANSFER
      return TransferService.new
    else
      raise ApiExceptions::BadRequestError.new(detail: "Unknown Transaction type", message: "Invalid Data.")
    end
  end
end
