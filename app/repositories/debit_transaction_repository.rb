# frozen_string_literal: true

class DebitTransactionRepository < BaseRepository
  def initialize(model = Debit)
    super(model)
  end
end
