module Spree
  class BankSlipsController < Spree::StoreController
    before_action :load_object, only: :show
    skip_before_action :set_current_order, only: :status_changed

    def show
      data = open(@slip.pdf)
      send_data data.read, filename: "boleto_#{@slip.id}.pdf", type: 'application/pdf'
    end

    def status_changed
      if params[:data]
        bank_slip = Spree::BankSlip.find_by invoice_id: params[:data][:id]

        case params[:data][:status].to_sym
          # Captura o pagamento
          when :paid then bank_slip.payment.capture!
          # Cancela o pagamento
          when :canceled, :expired then bank_slip.payment.void_transaction!
        end
      end
      render nothing: true, status: 200
    end

    private

    def load_object
      @slip = Spree::BankSlip.find params[:id] || params[:bank_slip_id]
    end

  end
end