FactoryBot.define do
  factory :wallet do
    name
    walletable_type
    walletable_id
    balance
    walletable
  end
end
