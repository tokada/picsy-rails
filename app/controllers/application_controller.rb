class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
	before_filter :select_theme

	def select_theme
		@themes = %w[
			amelia
			cerulean
			cosmo
			cyborg
			journal
			readable
			simplex
			slate
			spacelab
			spruce
			superhero
			united
		]
		if @themes.include?(session[:theme])
			@theme = session[:theme]
		else
			@theme = 'amelia'
		end
	end
end
