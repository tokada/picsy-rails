require 'matrix'

# 評価／Evaluation
#
# 商品を取引した際に買った人から売った人に出る感謝の印。貢献度の計算に用いる。
# マーケットに参加する人すべては、自分自身を含めたすべての人に対して評価の値を持っており、
# 他の人への評価値の増大が支払いに相当する。
# 自分自身を含めた全ての人への評価の値の合計は全ての人において一定値１である。
#
class Evaluation < ActiveRecord::Base
	belongs_to :market

  # ある評価は買った人からの評価となる
  belongs_to :buyable, :polymorphic => true

  # ある評価は売った人への評価となる
  belongs_to :sellable, :polymorphic => true

  # 人から人への評価のスコープ
  scope :for_person, -> { where(:buyable_type => 'Person', :sellable_type => 'Person') }

  # 評価は値をもつ
  attr_accessible :amount

  cattr_accessor :natural_recovery_ratio
  @@natural_recovery_ratio = 0.01

	before_save :insert_foreign_ids

	def insert_foreign_ids
		self.market = buyable_type.constantize.find(buyable_id).market
	end

  # 評価行列を取得する
  def self.person_matrix
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

	# 評価行列をゲーム用に整数化したもの
	def self.person_matrix_quantized(n=nil)
    n ||= (market.evaluation_parameter || 100000)
    person_matrix.to_a.map do |r|
      r.map{|c|
        q = c * n
        n <= 1 ? sprintf("%0.04f", q) : sprintf("%d", q)
      }
		end
	end

  # 自然回収
  def self.natural_recovery!(nr_ratio=@@natural_recovery_ratio)
    for_person.each do |ev|
      # 全評価から一定率を徴収
      ev.amount = (1 - nr_ratio) * ev.amount
      if ev.buyable == ev.sellable
        # 自己評価に自然回収率を上乗せ
        ev.amount = ev.amount + nr_ratio * (1 - ev.amount)
      end
      ev.save
    end
  end

end
