
class User < ApplicationRecord
  include BCrypt
  has_one :wallet, as: :walletable, dependent: :destroy
  after_create :create_wallet

  has_secure_password

  private

  def create_wallet
    Wallet.create!(walletable: self, name: "#{self.username}'s Wallet")
  end
end
