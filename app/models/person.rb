require 'matrix'
require 'picsy'

# 個人／Person
#
# 伝播投資貨幣を使用している個人。
#
class Person < ActiveRecord::Base
	belongs_to :market

  # 個人は他の経済主体に評価を与える
  has_many :given_evaluations, :as => :buyable, :class_name => 'Evaluation', :dependent => :destroy

  # 個人は他の経済主体から評価を与えられる
  has_many :earned_evaluations, :as => :sellable, :class_name => 'Evaluation', :dependent => :destroy

  # 個人は取引時に他の経済主体から商品を買い、その売主に評価を与える
  has_many :given_trades, :as => :buyable, :class_name => 'Trade', :dependent => :destroy

  # 個人は取引時に他の経済主体に商品を売り、その買主から評価をもらう
  has_many :earned_trades, :as => :sellable, :class_name => 'Trade', :dependent => :destroy

  # 個人は商品を所有する
  has_many :items, :as => :ownable

  # 個人は貢献度の伝播履歴をもつ
  has_many :propagations, :as => :evaluatable, :dependent => :destroy

  # 個人は名前をもつ
  attr_accessible :name

  # 個人は貢献度の値をもつ
  attr_accessible :contribution

  # 状態遷移
  state_machine :state, :initial => :alive do
    state :alive
    state :dead
    state :purged

    event :kill do
      transition :alive => :dead
    end

    event :resurrect do
      transition :dead => :alive
    end

    event :purge do
      transition :dead => :purged
    end
  end

  # 評価を与える取引を行う（支払う）
  def pay(seller, amount)
		transaction do
			trade = given_trades.create(:sellable => seller, :amount => amount)

			# 売り手の評価値を上げる
			e_bs = given_evaluations.where(:buyable => self, :sellable => seller).first_or_initialize
			e_bs.amount += amount
			e_bs.save

			# 買い手（自分）の評価値を下げる
			e_bb = given_evaluations.where(:buyable => self, :sellable => self).first_or_initialize
			e_bb.amount -= amount
			e_bb.save

			# 全員の貢献度を更新する
			old_contributions = Vector.elements(self.class.contributions)
			self.class.update_contributions!
			new_contributions = Vector.elements(self.class.contributions)
			diff = new_contributions - old_contributions

			# 貢献度の変化を伝播として記録する
			people_list = self.class.all
			diff.each.with_index do |amount, i|
				next if amount == 0.0
				prop = trade.propagations.build(:evaluatable => people_list[i], :amount => amount)
				if prop.evaluatable == self
					prop.category = "spence"
				elsif prop.evaluatable == seller
					prop.category = "earn"
				else
					prop.category = "effect"
				end
				prop.save
			end

			# 全員のPICSY効果を更新する
			self.class.update_picsy_effect!
		end
  end

  # 評価を得る取引を行う（稼ぐ）
  def earn(buyer, amount)
    buyer.pay(self, amount)
  end

  # 他の経済主体に評価を与える
  def evaluate!(seller, amount)
    ev = given_evaluations.where(:buyable => self, :sellable => seller).first_or_initialize
    ev.amount = amount
    ev.save
  end

  # 他の経済主体への評価値を取得する
  def evaluation_to(seller)
    Evaluation.where(:buyable => self, :sellable => seller).first.amount
  end

  # 他の経済主体からの評価値を取得する
  def evaluation_from(buyer)
    Evaluation.where(:buyable => buyer, :sellable => self).first.amount
  end

  # 自己評価値を取得する
  def self_evaluation
    evaluation_to(self)
  end

  # ゲーム用に自己評価値を整数化したもの
  def self_evaluation_quantized(n=100000)
		(self_evaluation * n).to_i
  end

  # PersonのID一覧と順番のハッシュ
  def self.id_seq
    pluck(:id).each.with_index.inject({}) do |h, (person_id, i)|
      h[person_id] = i
      h
    end
  end

  # 初期評価行列を生成する
  def self.initialize_matrix
    size = count
    v = (1.0 / (size - 1))
    # 対角要素（自己評価）は0.0、非対角要素は1.0を自己を除く評価対象数で配分したものとする
    Matrix.build(size) {|r, c| r == c ? 0.0 : v }
  end

  # 初期評価行列を生成し、永続化する
  def self.initialize_matrix!(matrix = initialize_matrix)
    Evaluation.delete_all
    all.each.with_index do |buyer, i|
      all.each.with_index do |seller, j|
        buyer.evaluate!(seller, matrix[i, j])
      end
    end
    update_contributions!
    matrix
  end

  # 貢献度の配列
  def self.contributions
    pluck(:contribution)
  end

  # 貢献度をゲーム用に整数化したもの
  def self.contributions_quantized(n=nil)
		n ||= (market.evaluation_parameter || 100000)
		contributions.map{|c| (c * n).to_i }
  end

  # 貢献度のハッシュ
  # { Person#id => Float, ... } のハッシュで返す
  def self.contributions_hash
    cs = contributions
    pluck(:id).each.with_index.inject({}) do |h, (person_id, i)|
      h[person_id] = cs[i]
      h
    end
  end

  def self.calculate_contributions(matrix=nil)
    matrix ||= Evaluation.person_matrix
    Picsy.calculate_contribution_by_markov(matrix)
  end

  # 貢献度をマルコフ過程によって更新する
  def self.update_contributions!(matrix=nil)
    contributions = calculate_contributions(matrix)
    all.each.with_index do |person, i|
      person.update_attribute(:contribution, contributions[i])
    end
    contributions
  end

	# PICSY効果
	def picsy_effect_quantized(n=100000)
		(picsy_effect.to_f * n).to_i
	end

	# PICSY効果を更新する
	def update_picsy_effect!
		effect = propagations.effect.pluck(:amount).sum
		update_attribute(:picsy_effect, effect)
	end

	# 全員のPICSY効果を更新する
	def self.update_picsy_effect!
		effects = {}
		Propagation.effect.each do |prop|
			effects[prop.evaluatable_id] ||= 0.0
			effects[prop.evaluatable_id] += prop.amount
		end
		effects.each_pair do |person_id, effect|
			Person.find(person_id).update_attribute(:picsy_effect, effect)
		end
	end

end
