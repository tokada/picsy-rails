PicsyRails::Application.routes.draw do
  get "admin/index"
  post "change_theme", :to => "home#change_theme"
  post "natural_recovery", :to => "demo#natural_recovery"
  post "trade", :to => "demo#trade"
  get "demo/index"

  resources :propagations
  resources :trades
  resources :evaluations
  resources :items
  resources :people

  root :to => 'demo#index'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new'
    get 'sign_out', :to => 'devise/sessions#destroy'
  end
end
