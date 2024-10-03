class CreateWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :wallets do |t|
      t.string :name, null: false
      t.references :walletable, polymorphic: true, index: true
      t.decimal :balance, precision: 15, scale: 2, default: 0.0, null: false

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
