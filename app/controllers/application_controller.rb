class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
	before_filter :select_theme

	def select_theme
		@themes = %w[
			amelia
			bootswatch
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
			@theme = 'bootswatch'
		end
	end

  before_filter do |controller|
    session[:last_url] = request.url unless request.url =~ %r!/users/!
  end

  def after_sign_in_path_for(resource)
    session[:last_url]
  end
end
