Devise.setup do |config|
  config.warden do |manager|
		manager.failure_app = CustomFailureApp
	end
end
