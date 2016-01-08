module Spree
  class BankSlip < ActiveRecord::Base

    has_one :payment, as: :source
    has_one :order, through: :payment
    belongs_to :user
    belongs_to :payment_method

    # Displays what actions can be done according to payments method
    #
    # @author Isabella Santos
    #
    # @return [Array]
    #
    def actions
      act = []
      act << 'capture' if can_capture? payment
      act << 'void' if can_void? payment
      act
    end

    # Save the amount of the billet
    # if amount is a string, convert to a BigDecimal
    #
    # copy of Spree::Payment.amount
    #
    def amount=(amount)
      self[:amount] =
          case amount
            when String
              separator = I18n.t('number.currency.format.separator')
              number    = amount.delete("^0-9-#{separator}\.").tr(separator, '.')
              number.to_d if number.present?
          end || amount
    end

    # Determines whether can capture the payments
    # (only can capture when the state is checkout or pending)
    #
    # @author Isabella Santos
    #
    # @return [Boolean]
    #
    def can_capture?(payment)
      payment.pending? || payment.checkout?
    end

    # Determines whether can void the payments
    # (only can void when the state is different of void, failure or invalid)
    #
    # @author Isabella Santos
    #
    # @return [Boolean]
    #
    def can_void?(payment)
      !%w(void failure invalid canceled).include?(payment.state)
    end

    # Defines the currency of the billet
    # based in te currency of the order
    #
    # copy of Spree::Payment.currency
    #
    def currency
      order.currency
    end

    # Return the amount converted to Money
    # according to currency
    #
    # copy of Spree::Payment.money
    #
    def money
      Spree::Money.new(amount, { currency: currency })
    end
    alias display_amount money

    # Returns if billet is paid
    #
    # @author Isabella Santos
    #
    # @return [Boolean]
    #
    def paid?
      status == 'paid'
    end

    # Returns if billet is pending
    #
    # @author Isabella Santos
    #
    # @return [Boolean]
    #
    def pending?
      status == 'pending'
    end

    # Returns if slip is canceled
    #
    # @author Isabella Santos
    #
    # @return [Boolean]
    #
    def canceled?
      status == 'canceled'
    end

  end
end