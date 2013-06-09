class CustomFailureApp < Devise::FailureApp
	def redirect 
		# will be called when some failure occurs. 
		# Like unauthorized, session_expiry etc
		message = warden.message || warden_options[:message]
		if message == :timeout
			# session expires
		else
			# unauthorized
			# redirect_to "facebook.com"
		end
		redirect_to user_omniauth_authorize_path(:twitter)
	end
end
