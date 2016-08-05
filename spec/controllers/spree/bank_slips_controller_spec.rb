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
      stub_iugu({ filename: 'fetch', method: :get, url: 'https://api.iugu.com/v1/invoices/1',
                  headers: {
                      'Accept'=>'application/json', 'Accept-Charset'=>'utf-8',
                      'Accept-Encoding'=>'gzip, deflate', 'Accept-Language'=>'pt-br;q=0.9,pt-BR',
                      'Content-Length'=>'2', 'Content-Type'=>'application/json; charset=utf-8',
                      'User-Agent'=>'Iugu RubyLibrary'
                  }, body: '{}' })
      stub_iugu({ filename: 'canceled', method: :put, body: '{}',
                  url: 'https://api.iugu.com/v1/invoices/1/cancel' })

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
      expect(slip.order.canceled?).to be true
    end

  end

end