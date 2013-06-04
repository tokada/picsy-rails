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
end
