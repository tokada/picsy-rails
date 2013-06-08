class HomeController < ApplicationController
  def index
  end

	def change_theme
		session[:theme] = params[:theme]
		redirect_to root_path
	end
end
