module Spree
  class BankSlipConfiguration < Spree::Preferences::Configuration

    preference :iugu_api_token, :string    # Token do Iugu
    preference :doc_customer_attr, :string # atributo que representa o documento do cliente

  end
end