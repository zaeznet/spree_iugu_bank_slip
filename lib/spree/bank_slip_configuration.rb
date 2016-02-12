module Spree
  class BankSlipConfiguration < Spree::Preferences::Configuration

    preference :iugu_api_token,    :string                  # Token do Iugu
    preference :doc_customer_attr, :string                  # Atributo que representa o documento do cliente
    preference :days_to_due_date,  :integer, default: 3     # Dias para a data de vencimento
    preference :ignore_due_email,  :boolean, default: true  # Ignorar email de cobranca

  end
end