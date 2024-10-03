# frozen_string_literal: true

class CreditTransactionRepository < BaseRepository
  def initialize(model = Credit)
    super(model)
  end
end
