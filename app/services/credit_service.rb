# frozen_string_literal: true

class CreditService
  include TransactionInterface

  TYPE_CREDIT = "credit"

  def initialize(
    credit_repo: CreditTransactionRepository.new,
    wallet_repo: WalletRepository.new
  )
    @credit_repo = credit_repo
    @wallet_repo = wallet_repo
  end

  def execute(user, data)
    raise ApiExceptions::BadRequestError.new(
      detail: "Amount should not be less than 0"
    ) if data[:amount] <= 0

    ActiveRecord::Base.transaction do
      source_wallet = @wallet_repo.find_by_id_with_lock!(data[:source_wallet_id])

      @credit_repo.create!({ amount: data[:amount], source_wallet: source_wallet })
      @wallet_repo.update!(source_wallet.id, { balance: source_wallet.balance + data[:amount] })
    end
  end
end
