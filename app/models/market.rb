# 市場／Market
#
# 取引が成立する場。一つの経済主体は単一の市場に参加する。
#
class Market < ActiveRecord::Base
	has_many :people, :counter_cache => true
	#has_many :evaluations
	#has_many :trades
	#has_many :propagations
end
