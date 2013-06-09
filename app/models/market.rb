# 市場／Market
#
# 取引が成立する場。一つの経済主体は単一の市場に参加する。
#
class Market < ActiveRecord::Base
	has_many :people, :counter_cache => true
	#has_many :evaluations
	#has_many :trades
	#has_many :propagations

	def set_default_name(current_user)
		name = current_user.name + "の市場"
		20.times do |i|
			if self.class.where(:name => name).first
				name = current_user.name + "の市場その" + (i+2)
			else
				break
			end
		end
		self.name = name
	end
end
