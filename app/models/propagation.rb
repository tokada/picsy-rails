# 伝播／Propagation
#
# 取引によって価値が他の経済主体へと波及すること
#
class Propagation < ActiveRecord::Base
	belongs_to :market

  # 伝播は一つの取引に属する
  belongs_to :trade

  # 伝播は評価対象者に属する
  belongs_to :evaluatable, :polymorphic => true
  attr_accessible :evaluatable

  # 伝播は評価値をもつ
  attr_accessible :amount

	before_save :insert_foreign_ids

	def insert_foreign_ids
		self.market = self.trade.market
	end

  # 伝播は種別をもつ
	# "spence": 支払った場合
	# "earn": 得た場合
	# "effect": PICSY効果による伝播の場合
  attr_accessible :category
	scope :spence, -> { where(evaluatable_type: "Person", category: "spence") }
	scope :earn  , -> { where(evaluatable_type: "Person", category: "earn")   }
	scope :effect, -> { where(evaluatable_type: "Person", category: "effect") }

	def spence?
		category == "spence"
	end

	def earn?
		category == "earn"
	end

	def effect?
		category == "effect"
	end

	# ゲーム用に整数化する
	def amount_quantized(n=100000)
		a = (amount * n).to_i
		if a == 0
			""
		else
			a.to_s
		end
	end
end
