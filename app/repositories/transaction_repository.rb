# frozen_string_literal: true

class TransactionRepository < BaseRepository
  def initialize(model = Transaction)
    super(model)
  end

  def get_total_balance(wallet_id)
    Transaction.where(source_wallet_id: wallet_id).sum(:amount)
  end
end
