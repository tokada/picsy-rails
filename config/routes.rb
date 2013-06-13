PicsyRails::Application.routes.draw do
  root :to => 'home#index'
  get "change_theme", :to => "home#change_theme"

  resources :markets do
		post :trade           , on: :member
		post :natural_recovery, on: :member
		put :open             , on: :member
		put :close            , on: :member
	end
  resources :people do
    get :partial, on: :member
  end
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
