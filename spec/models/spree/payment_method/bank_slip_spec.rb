require 'spec_helper'

describe Spree::PaymentMethod::BankSlip, type: :model do

  let(:object) { create(:slip_payment_method) }
  let(:slip) { create(:bank_slip) }

  before do
    create_response = JSON.parse File.read('spec/fixtures/iugu_responses/create.json')
    fetch_response = JSON.parse File.read('spec/fixtures/iugu_responses/fetch.json')

    # Stub da criacao da fatura
    stub_request(:post, 'https://api.iugu.com/v1/charge').
        with(headers: {'Accept'=>'application/json',
                       'Accept-Charset'=>'utf-8',
                       'Accept-Encoding'=>'gzip, deflate',
                       'Accept-Language'=>'pt-br;q=0.9,pt-BR',
                       'Content-Type'=>'application/json; charset=utf-8',
                       'User-Agent'=>'Iugu RubyLibrary'},
             body: hash_including({'method' => 'bank_slip'})).
        to_return(body: create_response.to_json, status: 200)

    # Stub da verificacao da fatura
    stub_request(:get, 'https://api.iugu.com/v1/invoices/1').
        with(headers: {'Accept'=>'application/json',
                       'Accept-Charset'=>'utf-8',
                       'Accept-Encoding'=>'gzip, deflate',
                       'Accept-Language'=>'pt-br;q=0.9,pt-BR',
                       'Content-Length'=>'2',
                       'Content-Type'=>'application/json; charset=utf-8',
                       'User-Agent'=>'Iugu RubyLibrary'},
             body: '{}').
        to_return(body: fetch_response.to_json, status: 200)
  end

  it 'authorize' do
    object.authorize '1599', slip, slip.payment.gateway_options

    expect(slip.amount).to eq 15.99
    expect(slip.invoice_id).to eq '1'
    expect(slip.payment_due).to eq Date.parse('2016-01-09')
    expect(slip.url).to eq 'http://localhost:3000'
    expect(slip.pdf).to eq 'http://localhost:3000.pdf'
    expect(slip.pending?).to be true
  end

  it 'capture' do
    object.capture '1599', '1', slip.payment.gateway_options

    expect(slip.reload.paid?).to be true
    expect(slip.paid_in).to eq Date.today
  end

  it 'void' do
    object.void '1', slip.payment.gateway_options

    expect(slip.reload.canceled?).to be true
  end

end