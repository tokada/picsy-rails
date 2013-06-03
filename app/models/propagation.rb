# 伝播／Propagation
#
# 取引によって価値が他の経済主体へと波及すること
#
class Propagation < ActiveRecord::Base
  # 伝播は一つの取引に属する
  belongs_to :trade
  # 伝播は価値を与える経済主体に属する
  belongs_to :actor_from, :polymorphic => true
  # 伝播は価値を貰う経済主体に属する
  belongs_to :actor_to, :polymorphic => true

  # 伝播は評価値をもつ
  attr_accessible :amount
end
