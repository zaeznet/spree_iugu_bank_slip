class CreateSpreeBankSlips < ActiveRecord::Migration
  def change
    create_table :spree_bank_slips do |t|
      t.string :invoice_id
      t.decimal :amount
      t.string :status
      t.date :payment_due
      t.date :paid_in
      t.string :url
      t.string :pdf
      t.references :payment_method
      t.references :user

      t.timestamps
    end
  end
end
