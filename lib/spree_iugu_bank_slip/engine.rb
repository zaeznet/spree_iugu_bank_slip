module SpreeIuguBankSlip
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_iugu_bank_slip'

    initializer 'spree.iugu_bank_slip.preferences', :after => :load_config_initializers do |app|
      # inicializa o objeto com as configuracoes do Iugu
      require 'spree/bank_slip_configuration'
      Spree::BankSlipConfig = Spree::BankSlipConfiguration.new

      # Insere no objeto do Iugu o token salvo
      Iugu.api_key = Spree::BankSlipConfig[:iugu_api_token]
    end

    initializer 'spree.iugu_bank_slip.payment_methods', :after => 'spree.register.payment_methods' do |app|
      app.config.spree.payment_methods << Spree::PaymentMethod::BankSlip
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
