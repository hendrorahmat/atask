class TransactionsController < ApplicationController
  def create
    data = validate_params!(TransactionDto.new)
    service = TransactionFactoryService.make(data)
    service.execute(@current_user, data)
    render json: { message: "Transfer successful" }, status: :created
  end
end
