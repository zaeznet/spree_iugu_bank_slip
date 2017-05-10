module Spree
  class BankSlipsController < Spree::StoreController

    before_action :load_object, only: [:show, :status_changed]
    skip_before_action :set_current_order, only: :status_changed
    skip_before_action :verify_authenticity_token, only: [:status_changed]

    def show
      data = open(@slip.pdf)
      send_data data.read, filename: "boleto_#{@slip.id}.pdf", type: 'application/pdf'
    end

    def status_changed
      if params[:data]
        case params[:data][:status].to_sym
          # Captura o pagamento
          when :paid then @slip.payment.capture!
          # Cancela o pagamento e o pedido
          when :canceled, :expired
            @slip.payment.void_transaction!
            # Pode ser que o pedido tenha sido completo por outro pagamento
            # esse e o motivo dessa verificacao
            @slip.order.cancel! if @slip.order.payment_state == 'balance_due'
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