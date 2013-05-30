# 評価／Evaluation
#
# 商品を取引した際に買った人から売った人に出る感謝の印。貢献度の計算に用いる。
# マーケットに参加する人すべては、自分自身を含めたすべての人に対して評価の値を持っており、
# 他の人への評価値の増大が支払いに相当する。
# 自分自身を含めた全ての人への評価の値の合計は全ての人において一定値１である。
#
class Evaluation < ActiveRecord::Base
  # ある評価は買った人からの評価となる
  # an actor (person/company) as a buyer evaluates seller actors
  belongs_to :buyable, :polymorphic => true

  # ある評価は売った人への評価となる
  # an actor (person/company) as a seller is evaluated by buyer actors
  belongs_to :sellable, :polymorphic => true
end
