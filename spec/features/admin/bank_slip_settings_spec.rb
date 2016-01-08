require 'spec_helper'

describe 'Bank Slip Settings', { type: :feature, js: true } do

  before { create_admin_in_sign_in }

  context 'show billet settings' do

    it 'should show bank slip settings' do
      visit spree.edit_admin_bank_slip_settings_path

      expect(page).to have_selector '#iugu_api_token'
      expect(page).to have_selector '#doc_customer_attr'
    end

  end

  context 'edit bank slip settings' do

    before { visit spree.edit_admin_bank_slip_settings_path }

    after(:all) do
      Spree::BankSlipConfig[:doc_customer_attr] = ''
      Spree::BankSlipConfig[:iugu_api_token] = ''
      Iugu.api_key = ''
    end

    it 'can edit Iugu api token' do
      fill_in 'iugu_api_token', with: 'abc1234'
      click_button 'Update'

      expect(Spree::BankSlipConfig[:iugu_api_token]).to eq 'abc1234'
      expect(find_field('iugu_api_token').value).to eq 'abc1234'
    end

    it 'can edit document customer attribute', js: true do
      select2 'Authentication Token', from: 'Doc. Customer Attribute'
      click_button 'Update'

      expect(Spree::BankSlipConfig[:doc_customer_attr]).to eq 'authentication_token'
      expect(find_field('doc_customer_attr').value).to eq 'authentication_token'
    end

  end
end