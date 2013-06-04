require 'matrix'
require 'picsy'

# 個人／Person
#
# 伝播投資貨幣を使用している個人。
#
class Person < ActiveRecord::Base
  # 個人は他の経済主体に評価を与える
  has_many :given_evaluations, :as => :buyable, :class_name => 'Evaluation'

  # 個人は他の経済主体から評価を与えられる
  has_many :earned_evaluations, :as => :sellable, :class_name => 'Evaluation'

  # 個人は取引時に他の経済主体から商品を買い、その売主に評価を与える
  has_many :given_trades, :as => :buyable, :class_name => 'Trade'

  # 個人は取引時に他の経済主体に商品を売り、その買主から評価をもらう
  has_many :earned_trades, :as => :sellable, :class_name => 'Trade'

  # 個人は商品を所有する
  has_many :items, :as => :ownable

  # 個人は貢献度の伝播履歴をもつ
  has_many :propagations, :as => :evaluatable

  # 個人は名前をもつ
  attr_accessible :name

  # 個人は貢献度の値をもつ
  attr_accessible :contribution

  # 評価を与える取引を行う（支払う）
  def pay(seller, amount)
    # TODO: should be transactional
    trade = given_trades.create(:sellable => seller, :amount => amount)

    # 売り手の評価値を上げる
    e_bs = given_evaluations.where(:buyable => self, :sellable => seller).first_or_initialize
    e_bs.amount += amount
    e_bs.save

    # 買い手の評価値を下げる
    e_bb = given_evaluations.where(:buyable => self, :sellable => self).first_or_initialize
    e_bb.amount -= amount
    e_bb.save

    # 貢献度を更新する
    old_contributions = Vector.elements(self.class.contributions)
    self.class.update_contributions!
    new_contributions = Vector.elements(self.class.contributions)
    diff = new_contributions - old_contributions

    # 貢献度の変化を伝播として記録する
    people_list = self.class.all
    diff.each.with_index do |amount, i|
      trade.propagations.create(:evaluatable => people_list[i], :amount => amount)
    end
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

  # PersonのID一覧
  def self.ids
    pluck(:id)
  end
  
  # PersonのID一覧と順番のハッシュ
  def self.id_seq
    ids.each.with_index.inject({}) do |h, (person_id, i)|
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

  # 貢献度のハッシュ
  # { Person#id => Float, ... } のハッシュで返す
  def self.contributions_hash
    cs = contributions
    ids.each.with_index.inject({}) do |h, (person_id, i)|
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
      person.contribution = contributions[i]
      person.save
    end
    contributions
  end

end
