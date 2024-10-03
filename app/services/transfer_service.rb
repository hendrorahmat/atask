class TransferService
  include TransactionInterface

  TYPE_TRANSFER = "transfer"

  def initialize(
    debit_repo: DebitTransactionRepository.new,
    credit_repo: CreditTransactionRepository.new,
    wallet_repo: WalletRepository.new,
    transaction_repo: TransactionRepository.new
  )
    @debit_repo = debit_repo
    @credit_repo = credit_repo
    @wallet_repo = wallet_repo
    @transaction_repo = transaction_repo
  end

  def execute(user, data)
    raise ApiExceptions::BadRequestError.new(
      detail: "Target or Source wallet cannot be blank"
    ) if data[:target_wallet_id].blank? || data[:source_wallet_id].blank?

    raise ApiExceptions::BadRequestError.new(
      detail: "Couldn't transfer to same wallet"
    ) if data[:target_wallet_id] == data[:source_wallet_id]

    ActiveRecord::Base.transaction do
      target_wallet = @wallet_repo.find_by_id_with_lock!(data[:target_wallet_id])
      source_wallet = @wallet_repo.find_by_id_with_lock!(data[:source_wallet_id])

      raise ApiExceptions::BadRequestError.new(
        detail: "User dont have access to this wallet"
      ) if source_wallet.walletable_type == "User" && user.wallet.id != data[:source_wallet_id]

      raise ApiExceptions::BadRequestError.new(detail: "Insufficient funds") if source_wallet.balance < data[:amount]

      @debit_repo.create!({ amount: data[:amount] * -1, source_wallet: source_wallet, target_wallet: target_wallet })
      @credit_repo.create!({ amount: data[:amount], target_wallet: source_wallet, source_wallet: target_wallet })

      @wallet_repo.update!(source_wallet.id, { balance: source_wallet.balance - data[:amount] })
      @wallet_repo.update!(target_wallet.id, { balance: target_wallet.balance + data[:amount] })
    end
  end
end
