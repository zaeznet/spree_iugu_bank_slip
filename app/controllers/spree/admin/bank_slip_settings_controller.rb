module Spree
  module Admin
    class BankSlipSettingsController< BaseController

      def edit
        @config = Spree::BankSlipConfiguration.new
        @user_attr = Spree::User.new.attribute_names.sort_by { |item| item }
      end

      def update
        config = Spree::BankSlipConfiguration.new

        params.each do |name, value|
          next unless config.has_preference?(name)
          config[name] = value
        end

        # Atualiza o token do Iugu
        Iugu.api_key = params[:iugu_api_token] if params[:iugu_api_token].present?

        flash[:success] = Spree.t(:successfully_updated, resource: Spree.t(:bank_slip_settings))
        redirect_to edit_admin_bank_slip_settings_path
      end

    end
  end
end