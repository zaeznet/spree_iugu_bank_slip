FactoryGirl.define do
  factory :slip_payment_method, class: Spree::PaymentMethod::BankSlip do
    name 'Bank Slip'
    created_at Date.today
  end

  factory :bank_slip, class: Spree::BankSlip do
    status 'pending'
    amount 10.0
    paid_in nil
    invoice_id 1
    payment_method FactoryGirl.build(:slip_payment_method)
    user
    association(:order, factory: :order)

    factory :bank_slip_with_payment do
      association(:payment, factory: :slip_payment_without_source)
    end
  end

  factory :slip_payment_without_source, class: Spree::Payment do
    amount 15.99
    association(:payment_method, factory: :slip_payment_method)
    association(:order, factory: :completed_order_with_totals)
    state 'checkout'
    response_code '1'

    factory :slip_payment do
      association(:source, factory: :bank_slip)
    end
  end
end
