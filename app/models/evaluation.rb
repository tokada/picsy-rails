require 'matrix'

# 評価／Evaluation
#
# 商品を取引した際に買った人から売った人に出る感謝の印。貢献度の計算に用いる。
# マーケットに参加する人すべては、自分自身を含めたすべての人に対して評価の値を持っており、
# 他の人への評価値の増大が支払いに相当する。
# 自分自身を含めた全ての人への評価の値の合計は全ての人において一定値１である。
#
class Evaluation < ActiveRecord::Base
  # ある評価は買った人からの評価となる
  belongs_to :buyable, :polymorphic => true

  # ある評価は売った人への評価となる
  belongs_to :sellable, :polymorphic => true

  attr_accessible :buyable, :sellable

  # 人から人への評価のスコープ
  scope :for_person, where(:buyable_type => 'Person', :sellable_type => 'Person')

  # 評価は値をもつ
  attr_accessible :amount

  # 評価行列を取得する
  def self.person_matrix
    # TODO: 更新ロックをかける
    a = []
    seq = Person.id_seq # { id1 => 0, id2 => 1, ... }
    for_person.find_each do |ev|
      next if seq[ev.buyable_id].nil? or seq[ev.sellable_id].nil? # TODO: warn
      i = seq[ev.buyable_id]
      j = seq[ev.sellable_id]
      a[i] ||= []
      a[i][j] = ev.amount
    end
    Matrix[*a]
  end

end
