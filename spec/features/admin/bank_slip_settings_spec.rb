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
      Spree::BankSlipConfig[:days_to_due_date] = 3
      Spree::BankSlipConfig[:ignore_due_email] = true
      Iugu.api_key = ''
    end

    it 'can edit Iugu api token' do
      fill_in 'iugu_api_token', with: 'abc1234'
      click_button 'Update'

      expect(Spree::BankSlipConfig[:iugu_api_token]).to eq 'abc1234'
      expect(find_field('iugu_api_token').value).to eq 'abc1234'
    end

    it 'can edit days to due date' do
      fill_in 'days_to_due_date', with: 10
      click_button 'Update'

      expect(Spree::BankSlipConfig[:days_to_due_date]).to eq 10
      expect(find_field('days_to_due_date').value).to eq '10'
    end

    it 'can edit ignore due email' do
      find(:css, '#ignore_due_email_false').set false
      click_button 'Update'

      expect(Spree::BankSlipConfig[:ignore_due_email]).to be false
      expect(find_field('ignore_due_email_false')).to be_checked
    end

    it 'can edit document customer attribute', js: true do
      select2 'Authentication Token', from: 'Doc. Customer Attribute'
      click_button 'Update'

      expect(Spree::BankSlipConfig[:doc_customer_attr]).to eq 'authentication_token'
      expect(find_field('doc_customer_attr').value).to eq 'authentication_token'
    end

  end
end