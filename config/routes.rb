Spree::Core::Engine.routes.draw do

  namespace :admin do
    resource :bank_slip_settings, only: [:show, :edit, :update]
  end

  resources :bank_slips, only: [:show] do
    # Rota para a mudanca de status da fatura enviada pelo Iugu
    post 'status_changed'
    get  'status_changed'
  end

end
