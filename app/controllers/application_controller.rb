class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
	before_filter :select_theme

	def select_theme
		@theme = session[:theme] || 'amelia'
	end
end
