Spree::Core::Engine.routes.draw do

  namespace :admin do
    resource :bank_slip_settings, only: [:show, :edit, :update]
  end

  # Rota para o download do boleto
  get  'bank_slips/:id', to: 'bank_slips#show', as: :bank_slip
  # Rota para a mudanca de status da fatura enviada pelo Iugu
  post 'bank_slips/status_changed', to: 'bank_slips#status_changed'


end
