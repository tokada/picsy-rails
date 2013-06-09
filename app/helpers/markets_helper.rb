module MarketsHelper
	def owner?
		current_user == @market.user
	end
end
