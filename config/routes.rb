PicsyRails::Application.routes.draw do
  resources :trades

  resources :evaluations

  resources :items

  resources :people

  root :to => 'home#index'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new'
    get 'sign_out', :to => 'devise/sessions#destroy'
  end
end
