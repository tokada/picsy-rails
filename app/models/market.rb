require 'matrix'
require 'picsy'
require 'american_name'

# 市場／Market
#
# 取引が成立する場。一つの経済主体は単一の市場に参加する。
#
class Market < ActiveRecord::Base
  belongs_to :user

  # 市場は取引に参加する複数の個人を持つ
  has_many :people, :dependent => :destroy, :counter_cache => true do

    # PersonのID一覧と順番のハッシュ
    def id_seq
      pluck(:id).each.with_index.inject({}) do |h, (person_id, i)|
        h[person_id] = i
        h
      end
    end

    # 初期評価行列を生成する
    def initialize_matrix(self_evaluation=0.0)
      size = proxy_association.target.count
      parameter = 1.0 - self_evaluation
      v = (parameter / (size - 1))
      # 非対角要素は1.0を自己評価値を除く評価対象数で配分したものとする
      Matrix.build(size) {|r, c| r == c ? self_evaluation : v }
    end

    # 初期評価行列を生成し、永続化する
    def initialize_matrix!(self_evaluation=0.0, matrix=nil)
      transaction do
        matrix ||= initialize_matrix(self_evaluation)
        proxy_association.owner.evaluations.delete_all
        proxy_association.target.each.with_index do |buyer, i|
          proxy_association.target.each.with_index do |seller, j|
            buyer.evaluate!(seller, matrix[i, j])
          end
        end
        update_contributions!
        matrix
      end
    end

    # 貢献度の配列
    def contributions
      pluck(:contribution)
    end

    # 貢献度をゲーム用に整数化したもの
    def contributions_quantized(n=nil)
      n = proxy_association.owner.evaluation_parameter || 100000
      contributions.map{|c| (c * n).to_i }
    end

    # 貢献度のハッシュ
    # { Person#id => Float, ... } のハッシュで返す
    def contributions_hash
      cs = contributions
      pluck(:id).each.with_index.inject({}) do |h, (person_id, i)|
        h[person_id] = cs[i]
        h
      end
    end

    def evaluations
      proxy_association.owner.evaluations
    end

    # 評価行列を取得する
    def person_matrix
      transaction do
        a = []
        seq = id_seq # { id1 => 0, id2 => 1, ... }
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

    def calculate_contributions(matrix=nil)
      matrix ||= person_matrix
      Picsy.calculate_contribution_by_markov(matrix)
    end

    # 貢献度をマルコフ過程によって更新する
    def update_contributions!(matrix=nil)
      contributions = calculate_contributions(matrix)
      proxy_association.target.each.with_index do |person, i|
        person.update_attribute(:contribution, contributions[i])
      end
      contributions
    end

  end

  has_many :evaluations, :dependent => :destroy
  has_many :trades, :dependent => :destroy, :counter_cache => true
  has_many :propagations, :dependent => :destroy

  attr_accessible :name, :people_count,
    :evaluation_parameter, :initial_self_evaluation, :natural_recovery_ratio

  validates :name, :people_count, :evaluation_parameter, :initial_self_evaluation,
            :natural_recovery_ratio, :presence => true

  after_create :create_people

  attr_accessor :natural_recovery_ratio_percent

  def natural_recovery_ratio_percent
    (natural_recovery_ratio.to_f * 100).to_i
  end

  def natural_recovery_ratio_percent=(percent)
    self.natural_recovery_ratio = percent / 100.0
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
    people.initialize_matrix!(self_evaluation_by_ratio)
  end

  def self_evaluation_by_ratio
    initial_self_evaluation == 0 ? 0.0 : initial_self_evaluation.to_f / evaluation_parameter.to_f
  end

  def matrix
    people.person_matrix
  end
  
  # 評価行列をゲーム用に整数化したもの
  def matrix_quantized(n=nil)
    n ||= (self.evaluation_parameter || 100000)
    Picsy.fix_matrix(matrix).to_a.map do |r|
      r.map{|c| (c * n).to_i }
    end
  end

  # 自然回収
  def natural_recovery!(nr_ratio=nil)
    nr_ratio ||= natural_recovery_ratio
    return if nr_ratio.zero?
    transaction do
      evaluations.for_person.each do |ev|
        # 全評価から一定率を徴収
        ev.amount = (1 - nr_ratio) * ev.amount
        if ev.buyable == ev.sellable
          # 自己評価に自然回収率を上乗せ
          ev.amount = ev.amount + nr_ratio * (1 - ev.amount)
        end
        ev.save
      end
      if nr_ratio != natural_recovery_ratio
        self.natural_recovery_ratio = nr_ratio
      end
      self.last_natural_recovery_at = Time.now
      save
    end
  end
end
