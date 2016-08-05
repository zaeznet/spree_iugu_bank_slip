module Spree
  class PaymentMethod
    class PaymentMethod::BankSlip < PaymentMethod

      # Nao existe captura automatica para o metodo do tipo boleto
      def auto_capture
        false
      end

      def payment_source_class
        Spree::BankSlip
      end

      # Redireciona para o metodo de autorizacao
      # pois nao ha captura automatica
      #
      def purchase(amount, source, *args)
        self.authorize(amount, source, args)
      end

      # Autoriza o pagamento
      # enviando as informacoes ao Iugu
      #
      # @author Isabella Santos
      #
      # @return [ActiveMerchant::Billing::Response]
      #
      def authorize(amount, source, *args)
        gateway_options = args.first
        user = Spree::User.find gateway_options[:customer_id]
        doc_user = user.attributes[Spree::BankSlipConfig[:doc_customer_attr]] rescue ''
        billing_address = gateway_options[:billing_address]

        # Pegando o DDD e o telefone
        if billing_address[:phone].include?('(')
          phone_prefix = billing_address[:phone][1..2]  rescue ''
          phone = billing_address[:phone][5..-1] rescue ''
        else
          phone_prefix = nil
          phone = billing_address[:phone]
        end

        notification_url = Spree::BankSlipConfig[:store_url]
        notification_url << Spree::Core::Engine.routes.url_helpers.bank_slip_status_changed_path(source.id)

        due_date = Date.today + Spree::BankSlipConfig[:days_to_due_date].days

        iugu_params = {
            method: 'bank_slip',
            email: gateway_options[:email],
            notification_url: notification_url,
            due_date: due_date.strftime('%d/%m/%Y'),
            ignore_due_email: Spree::BankSlipConfig[:ignore_due_email],
            items: [],
            payer: {
                cpf_cnpj: doc_user,
                name: billing_address[:name],
                phone_prefix: phone_prefix,
                phone: phone,
                email: gateway_options[:email],
                address: {
                    street: billing_address[:address1],
                    city: billing_address[:city],
                    state: billing_address[:state],
                    country: 'Brasil',
                    zip_code: billing_address[:zip]
                }
            }
        }

        source.order.line_items.each do |item|
          iugu_params[:items] << {
              description: item.variant.name,
              quantity: item.quantity,
              price_cents: item.single_money.cents
          }
        end

        # Cria um item para o frete a ser cobrado
        if source.order.shipment_total > 0
          iugu_params[:items] << {
              description: Spree.t(:shipment_total),
              quantity: 1,
              price_cents: source.order.display_ship_total.cents
          }
        end

        # Insere os adjustments na fatura
        source.order.all_adjustments.eligible.each do |adj|
          iugu_params[:items] << {
              description: adj.label,
              quantity: 1,
              price_cents: adj.display_amount.cents
          }
        end

        invoice = Iugu::Invoice.create(iugu_params)

        if Spree::BankSlipConfig[:log_requests]
          logger = Logger.new Rails.root.join('log', "#{Rails.env}.log")
          logger.debug "Request Iugu: #{iugu_params}"
          logger.debug "Response Iugu: #{invoice.attributes}" if invoice.respond_to? :attributes
        end

        if invoice.errors
          errors = invoice.errors.collect { |k, v| v.collect { |i| "#{k} #{i}" }.join(', ') }.join(', ')
          ActiveMerchant::Billing::Response.new(false, errors, {}, {})
        else
          source.amount = amount.to_d / 100
          source.invoice_id = invoice.attributes['id']
          source.payment_due = invoice.attributes['due_date']
          source.url = invoice.attributes['secure_url']
          source.pdf = "#{invoice.attributes['secure_url']}.pdf"

          if source.save
            ActiveMerchant::Billing::Response.new(true, Spree.t('bank_slip.messages.successfully_authorized'), {}, authorization: invoice.attributes['id'])
          else
            ActiveMerchant::Billing::Response.new(false, Spree.t('bank_slip.messages.source_fail'), {}, authorization: invoice.attributes['id'])
          end
        end
      rescue
        ActiveMerchant::Billing::Response.new(false, Spree.t('bank_slip.messages.iugu_fail'), {}, {})
      end

      # Captura o pagamento
      # modificando o status e salvando a data
      #
      # @author Isabella Santos
      #
      # @return [ActiveMerchant::Billing::Response]
      #
      def capture(amount, response_code, gateway_options)
        bank_slip = Spree::BankSlip.find_by invoice_id: response_code
        bank_slip.amount = amount.to_d / 100
        bank_slip.paid_in = Date.today
        bank_slip.status = 'paid'
        bank_slip.save

        ActiveMerchant::Billing::Response.new(true, Spree.t('bank_slip.messages.successfully_captured'), {}, authorization: response_code)
      rescue
        ActiveMerchant::Billing::Response.new(false, Spree.t('bank_slip.messages.capture_fail'), {}, {})
      end

      # Cancela o pagamento
      #
      # @author Isabella Santos
      #
      # @return [ActiveMerchant::Billing::Response]
      #
      def void(response_code, _gateway_options)
        bank_slip = Spree::BankSlip.find_by invoice_id: response_code
        return ActiveMerchant::Billing::Response.new(false, Spree.t('bank_slip.messages.void_fail'), {}, {}) if bank_slip.nil?

        # Verifica na Iugu se o boleto esta pendente
        # se tiver, faz o cancelamento
        invoice = Iugu::Invoice.fetch response_code
        if invoice.status == 'pending'
          invoice.cancel
        end
        bank_slip.update_attribute(:status, 'canceled')

        ActiveMerchant::Billing::Response.new(true, Spree.t('bank_slip.messages.successfully_voided'), {}, authorization: response_code)
      rescue
        ActiveMerchant::Billing::Response.new(false, Spree.t('bank_slip.messages.void_fail'), {}, {})
      end

      # Cancela o pagamento
      #
      # @author Isabella Santos
      #
      # @return [ActiveMerchant::Billing::Response]
      #
      def cancel(response_code)
        bank_slip = Spree::BankSlip.find_by invoice_id: response_code
        return ActiveMerchant::Billing::Response.new(false, Spree.t('bank_slip.messages.void_fail'), {}, {}) if bank_slip.nil?

        # Verifica na Iugu se o boleto esta pendente
        # se tiver, faz o cancelamento
        invoice = Iugu::Invoice.fetch response_code
        if invoice.status == 'pending'
          invoice.cancel
        end
        bank_slip.update_attribute(:status, 'canceled')

        ActiveMerchant::Billing::Response.new(true, Spree.t('bank_slip.messages.successfully_voided'), {}, authorization: response_code)
      rescue
        ActiveMerchant::Billing::Response.new(false, Spree.t('bank_slip.messages.void_fail'), {}, {})
      end
    end
  end
end