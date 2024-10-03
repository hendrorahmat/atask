# frozen_string_literal: true

class DebitService
  include TransactionInterface

  TYPE_DEBIT = "debit"

  def initialize(
    debit_repo: DebitTransactionRepository.new,
    wallet_repo: WalletRepository.new
  )
    @debit_repo = debit_repo
    @wallet_repo = wallet_repo
  end

  def execute(user, data)
    raise ApiExceptions::BadRequestError.new(
      detail: "Amount should not be less than 0"
    ) if data[:amount] <= 0

    ActiveRecord::Base.transaction do
      source_wallet = @wallet_repo.find_by_id_with_lock!(data[:source_wallet_id])

      raise ApiExceptions::BadRequestError.new(
        detail: "User dont have access to this wallet"
      ) if source_wallet.walletable_type == "User" && user.wallet.id != source_wallet.id

      raise ApiExceptions::BadRequestError.new(detail: "Insufficient funds") if source_wallet.balance < data[:amount].to_f

      @debit_repo.create!({ amount: data[:amount] * -1, source_wallet: source_wallet })
      @wallet_repo.update!(source_wallet.id, { balance: source_wallet.balance - data[:amount] })
    end
  end
end
