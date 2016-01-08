require 'spree_core'
require 'spree_iugu_bank_slip/engine'

Spree::PermittedAttributes.source_attributes.push [:user_id, :status]