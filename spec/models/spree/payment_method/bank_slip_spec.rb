require 'spec_helper'

describe Spree::PaymentMethod::BankSlip, type: :model do

  let(:object) { create(:slip_payment_method) }
  let!(:slip) { create(:bank_slip) }

  before { Iugu.api_key = '' }

  it 'payment_source_class should be BankSlip' do
    expect(object.payment_source_class).to eq Spree::BankSlip
  end

  it 'payment method should not be auto captured' do
    expect(object.auto_capture).to be_falsey
  end

  context 'authorize' do

    it 'should authorize when Iugu create the invoice' do
      stub_iugu
      response = object.authorize '1599', slip, slip.payment.gateway_options

      expect(response.success?).to be_truthy
      expect(slip.amount).to eq 15.99
      expect(slip.invoice_id).to eq '1'
      expect(slip.payment_due).to eq Date.parse('2016-01-09')
      expect(slip.url).to eq 'http://localhost:3000'
      expect(slip.pdf).to eq 'http://localhost:3000.pdf'
      expect(slip.pending?).to be true
    end

    it 'should unauthorize when Iugu return error' do
      stub_iugu 'create_error'
      Spree::BankSlipConfig[:days_to_due_date] = -10
      response = object.authorize '1599', slip, slip.payment.gateway_options

      expect(response.success?).to be_falsey
    end

  end

  it 'capture' do
    object.capture '1599', '1', slip.payment.gateway_options

    expect(slip.reload.paid?).to be_truthy
    expect(slip.paid_in).to eq Date.today
  end

  context 'void' do
    it 'should void successfully' do
      object.void '1', slip.payment.gateway_options
      expect(slip.reload.canceled?).to be_truthy
    end

    it 'should return error when bank slip not found' do
      response = object.void 10, slip.payment.gateway_options
      expect(response.success?).to be_falsey
      expect(slip.reload.canceled?).to be_falsey
    end
  end

  context 'cancel' do
    it 'should cancel successfully' do
      object.cancel 1
      expect(slip.reload.canceled?).to be_truthy
    end

    it 'should return error when bank slip not found' do
      response = object.cancel 10
      expect(response.success?).to be_falsey
    end
  end

  def stub_iugu(filename = 'create')
    create_response = JSON.parse File.read("spec/fixtures/iugu_responses/#{filename}.json")

    # Stub da criacao da fatura
    stub_request(:post, 'https://api.iugu.com/v1/invoices').
        with(headers: {'Accept'=>'application/json',
                       'Accept-Charset'=>'utf-8',
                       'Accept-Encoding'=>'gzip, deflate',
                       'Accept-Language'=>'pt-br;q=0.9,pt-BR',
                       'Content-Type'=>'application/json; charset=utf-8',
                       'User-Agent'=>'Iugu RubyLibrary'},
             body: hash_including({'method' => 'bank_slip'})).
        to_return(body: create_response.to_json, status: 200)
  end

end