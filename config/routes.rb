PicsyRails::Application.routes.draw do
  root :to => 'home#index'

  get "admin/index"
  post "change_theme", :to => "home#change_theme"
  post "natural_recovery", :to => "demo#natural_recovery"
  post "trade", :to => "demo#trade"
  get "demo/index"

  resources :markets
  resources :people
  resources :evaluations
  resources :items
  resources :trades
  resources :propagations

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new'
    get 'sign_out', :to => 'devise/sessions#destroy'
  end
end
