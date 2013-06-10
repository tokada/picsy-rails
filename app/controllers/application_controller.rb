class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_filter do |controller|
    session[:last_url] = request.url unless request.url =~ %r!/users/!

		@themes = %w[
			amelia
			cerulean
			cosmo
			cyborg
			flatly
			journal
			readable
			simplex
			slate
			spacelab
			spruce
			superhero
			united
		]
  end

  def after_sign_in_path_for(resource)
    session[:last_url]
  end
end
