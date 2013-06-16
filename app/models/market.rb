require 'matrix'
require 'picsy'
require 'american_name'

# 市場／Market
#
# 取引が成立する場。一つの経済主体は単一の市場に参加する。
#
class Market < ActiveRecord::Base
  belongs_to :user

  # 状態遷移
  state_machine :state, :initial => :opened do
    state :opened
    state :closed

    event :close! do
      transition :opened => :closed
    end

    event :open! do
      transition :closed => :opened
    end
  end

  # 市場は取引に参加する複数の個人を持つ
  has_many :people, :dependent => :destroy, :counter_cache => true do

    # PersonのID一覧と順番のハッシュ
    def id_seq_hash
      pluck(:id).each.with_index.inject({}) do |h, (person_id, i)|
        h[person_id] = i
        h
      end
    end
  end

  has_many :evaluations, :dependent => :destroy
  has_many :trades, :dependent => :destroy, :counter_cache => true
  has_many :propagations, :dependent => :destroy
  has_many :natural_recoveries, :dependent => :destroy

  attr_accessible :name, :description, :people_count, :system,
    :evaluation_parameter, :initial_self_evaluation, :natural_recovery_ratio

  validates :name, :people_count, :evaluation_parameter, :initial_self_evaluation,
            :natural_recovery_ratio, :presence => true

  validates :natural_recovery_ratio_percent, :numericality => true
  validates :natural_recovery_ratio_percent, :inclusion => { :in => 1..99 }

  validates :people_count, :inclusion => { :in => 2..99 }

  validate :ise_should_be_no_more_than_ep

  def ise_should_be_no_more_than_ep
    if initial_self_evaluation > evaluation_parameter
      errors.add :initial_self_evaluation, "は評価値の母数 #{evaluation_parameter} 以下である必要があります。"
    end
  end

  after_create :create_people

  attr_accessible :natural_recovery_ratio_percent

  def natural_recovery_ratio_percent
    (natural_recovery_ratio.to_f * 100).to_i
  end

  def natural_recovery_ratio_percent=(percent)
    self.natural_recovery_ratio = percent.to_f / 100.0
  end

  # 名称の初期値をセットする
  # 「#{Twitter ID}の市場その20」までかぶっていたら諦める
  def set_default_name(current_user)
    name = current_user.name + "の市場"
    2.upto(20) do |i|
      if self.class.where(:name => name).first
        name = current_user.name + "の市場その#{i}"
      else
        break
      end
    end
    self.name = name
  end

  def create_people
    count = people_count
    people.delete_all
    names = AmericanName.pick_even(count).map(&:capitalize).sort
    count.times {|i| people.create(:name => names[i]) }
    initialize_matrix!(self_evaluation_by_ratio)
  end

  def self_evaluation_by_ratio
    initial_self_evaluation == 0 ? 0.0 : initial_self_evaluation.to_f / evaluation_parameter.to_f
  end

  # 初期評価行列を生成する
  def initialize_matrix(self_evaluation=0.0)
    size = people.count
    parameter = 1.0 - self_evaluation
    v = (parameter / (size - 1))
    # 非対角要素は1.0を自己評価値を除く評価対象数で配分したものとする
    Matrix.build(size) {|r, c| r == c ? self_evaluation : v }
  end

  # 初期評価行列を生成し、永続化する
  def initialize_matrix!(self_evaluation=0.0, matrix=nil)
    transaction do
      matrix ||= initialize_matrix(self_evaluation)
      evaluations.delete_all
      people.each.with_index do |buyer, i|
        people.each.with_index do |seller, j|
          buyer.evaluate!(seller, matrix[i, j])
        end
      end
      update_contributions!
      matrix
    end
  end

  # 貢献度の配列
  def contributions
    people.pluck(:contribution)
  end

  # 貢献度をゲーム用に整数化したもの
  def contributions_quantized(n=nil)
    n = evaluation_parameter || 100000
    contributions.map{|c| 
      q = c * n
      n <= 1 ? sprintf("%0.04f", q) : sprintf("%d", q)
    }
  end

  # 評価行列を取得する
  def matrix
    transaction do
      a = []
      seq = people.id_seq_hash # { id1 => 0, id2 => 1, ... }
      evaluations.find_each do |ev|
        next if seq[ev.buyable_id].nil? or seq[ev.sellable_id].nil? # TODO: warn
        i = seq[ev.buyable_id]
        j = seq[ev.sellable_id]
        a[i] ||= []
        a[i][j] = ev.amount
      end
      Matrix[*a]
    end
  end

  def matrix=(m)
    transaction do
      initialize_matrix!(0.0, m)
      trades.each(&:destroy)
    end
  end

  def calculate_contributions(m=nil)
    m ||= matrix
    if secsy?
      evaluations.pluck(:sellable_id, :amount).inject({}) do |h, (person_id, amount)|
        h[person_id] ||= 0
        h[person_id] += amount 
        h
      end.to_a.sort{|a,b| b[0] <=> a[0] }.map{|v| v[1] }
    else
      Picsy.calculate_contribution_by_markov(m)
    end
  end

  # 貢献度をマルコフ過程によって更新する
  def update_contributions!(m=nil)
    contributions = calculate_contributions(m)
    people.each.with_index do |person, i|
      person.update_attribute(:contribution, contributions[i])
    end
    contributions
  end

  # 評価行列をゲーム用に整数化したもの
  def matrix_quantized(n=nil)
    n ||= (self.evaluation_parameter || 100000)
    Picsy.fix_matrix(matrix).to_a.map do |r|
      r.map{|c| 
        q = c * n
        n <= 1 ? sprintf("%0.04f", q) : sprintf("%d", q)
      }
    end
  end

  # 自然回収
  def natural_recovery!(nr_ratio=nil)
    nr_ratio ||= natural_recovery_ratio
    return if nr_ratio.zero?
    transaction do
      nr_history = natural_recoveries.build(:ratio => nr_ratio)
      evaluations.for_person.each do |ev|
        # 全評価から一定率を徴収
        ev.amount *= (1 - nr_ratio)
        if ev.buyable == ev.sellable
          # 自己評価に自然回収率を上乗せ
          additions = nr_ratio * (1 - ev.amount)
          nr_history.add(ev.buyable, additions)
          ev.amount += additions
        end
        ev.save
      end
      if nr_ratio != natural_recovery_ratio
        self.natural_recovery_ratio = nr_ratio
      end
      nr_history.save
      self.last_natural_recovery_at = nr_history.created_at
      save
    end
  end

  def human_last_trade_at
    last_trade_at.nil? ? '' : last_trade_at.to_date
  end

  # 評価を与える取引を行う（支払う）
  def trade(buyer, seller, amount)
    transaction do
      trade = trades.create(:buyable => buyer, :sellable => seller, :amount => amount)

      # 買い手から売り手への評価値を上げる
      e_bs = evaluations.where(:buyable => buyer, :sellable => seller).first_or_initialize
      e_bs.amount += amount
      e_bs.save

      # 買い手の自己評価値を下げる
      e_bb = evaluations.where(:buyable => buyer, :sellable => buyer).first_or_initialize
      e_bb.amount -= amount
      e_bb.save

      # 全員の貢献度を更新する
      old_contributions = Vector.elements(contributions)
      update_contributions!(nil)
      new_contributions = Vector.elements(contributions)
      diff = new_contributions - old_contributions

      # 貢献度の変化を伝播として記録する
      diff.each.with_index do |amount, i|
        next if amount == 0.0
        prop = trade.propagations.build(:evaluatable => people[i], :amount => amount)
        if prop.evaluatable == buyer
          prop.category = "spence"
        elsif prop.evaluatable == seller
          prop.category = "earn"
        else
          prop.category = "effect"
        end
        prop.save
      end

      # 全員のPICSY効果を更新する
      update_picsy_effect!

      # 市場の更新日を更新
      touch(:last_trade_at)
    end
  end

  # 全員のPICSY効果を更新する
  def update_picsy_effect!
    effects = {}
    propagations.effect.each do |prop|
      effects[prop.evaluatable_id] ||= 0.0
      effects[prop.evaluatable_id] += prop.amount
    end
    effects.each_pair do |person_id, effect|
      Person.find(person_id).update_attribute(:picsy_effect, effect)
    end
  end

  # 前回の貢献度の増減
  def last_propagations
    trades.order("id desc").first.filled_propagations if trades.present?
  end

  # 履歴情報（自然回収歴、取引履歴）を並べたリスト
  def nr_or_trades
    (trades + natural_recoveries).sort{|a,b| b.created_at <=> a.created_at }
  end

  def picsy?
    system == "PICSY"
  end

  def secsy?
    system == "SECSY"
  end
end
