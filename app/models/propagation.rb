# 伝播／Propagation
#
# 取引によって価値が他の経済主体へと波及すること
#
class Propagation < ActiveRecord::Base
  # 伝播は一つの取引に属する
  belongs_to :trade

  # 伝播は評価対象者に属する
  belongs_to :evaluatable, :polymorphic => true
  attr_accessible :evaluatable

  # 伝播は評価値をもつ
  attr_accessible :amount

	def amount_quantized(n=100000)
		a = (amount * n).to_i
		if a == 0
			""
		else
			a.to_s
		end
	end
end
