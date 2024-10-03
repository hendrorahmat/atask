class TransactionDto < Dry::Schema::Params
  define do
    required(:type).filled(:string)
    required(:amount).value(:float, gt?: 0)
    required(:source_wallet_id).filled(:integer)
    optional(:target_wallet_id).maybe(:integer)
  end
end