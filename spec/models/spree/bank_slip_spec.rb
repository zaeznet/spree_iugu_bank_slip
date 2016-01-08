require 'spec_helper'

describe Spree::BankSlip, type: :model do

  let(:payment) { FactoryGirl.build(:payment) }
  let(:slip)    { FactoryGirl.build(:bank_slip, status: 'pending', payment: payment) }

  it 'should return true when slip is pending' do
    expect(slip.pending?).to be true
  end

  context 'actions options' do
    it 'should return when can capture the slip' do
      payment.state = 'checkout'
      expect(slip.can_capture?(payment)).to be true

      payment.state = 'pending'
      expect(slip.can_capture?(payment)).to be true

      payment.state = 'void'
      expect(slip.can_capture?(payment)).to be false
    end

    it 'should return when can void the slip' do
      payment.state = 'checkout'
      expect(slip.can_void?(payment)).to be true

      payment.state = 'pending'
      expect(slip.can_void?(payment)).to be true

      payment.state = 'processing'
      expect(slip.can_void?(payment)).to be true

      payment.state = 'void'
      expect(slip.can_void?(payment)).to be false

      payment.state = 'failure'
      expect(slip.can_void?(payment)).to be false

      payment.state = 'invalid'
      expect(slip.can_void?(payment)).to be false
    end

    it 'should return the actions to payments according to state' do
      payment.state = 'checkout'
      expect(slip.actions).to eq %w(capture void)

      payment.state = 'processing'
      expect(slip.actions).to eq %w(void)

      payment.state = 'void'
      expect(slip.actions).to eq []
    end
  end

end