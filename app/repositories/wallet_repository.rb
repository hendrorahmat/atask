# frozen_string_literal: true

class WalletRepository < BaseRepository
  def initialize(model = Wallet)
    super(model)
  end

  def find_by_id_with_lock!(id)
    @model.lock.find(id)
  end
end
