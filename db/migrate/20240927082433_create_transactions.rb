class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.references :source_wallet, foreign_key: { to_table: :wallets }
      t.references :target_wallet, foreign_key: { to_table: :wallets }
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :type, null: false # For STI
      t.timestamps
      t.datetime :deleted_at
    end
  end
end
