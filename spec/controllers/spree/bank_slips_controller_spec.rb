require 'spec_helper'

describe Spree::BankSlipsController, type: :controller do

  let(:slip) { create(:bank_slip_with_payment) }

  context '#status_changed' do

    it 'should change status to paid' do
      request_params = {
          bank_slip_id: slip.id,
          data: {
              id: slip.id,
              status: 'paid'
          }
      }
      post :status_changed, request_params

      expect(response.status).to eq 200
      expect(slip.reload.paid?).to be true
    end

    it 'should change status to canceled' do
      request_params = {
          bank_slip_id: slip.id,
          data: {
              id: slip.id,
              status: 'canceled'
          }
      }
      post :status_changed, request_params

      expect(response.status).to eq 200
      expect(slip.reload.canceled?).to be true
    end

  end

end