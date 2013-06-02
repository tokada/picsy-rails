require 'matrix'

# 個人／Person
#
# 伝播投資貨幣を使用している個人。
#
class Person < ActiveRecord::Base
  # 個人は他の経済主体に評価を与える
  has_many :given_evaluations, :as => :buyable, :class_name => 'Evaluation' do
    # sellerへの評価を取得する
    def to(seller)
      proxy_association.reload.target.find(:sellable => seller).first
    end
  end

  # 個人は他の経済主体から評価を与えられる
  has_many :earned_evaluations, :as => :sellable, :class_name => 'Evaluation' do
    # buyerからの評価を取得する
    def from(buyer)
      proxy_association.reload.target.find(:buyable => buyer).first
    end
  end

  # 個人は取引時に他の経済主体から商品を買い、その売主に評価を与える
  has_many :given_trades, :as => :buyable, :class_name => 'Trade'

  # 個人は取引時に他の経済主体に商品を売り、その買主から評価をもらう
  has_many :earned_trades, :as => :sellable, :class_name => 'Trade'

  # 個人は商品を所有する
  has_many :items, :as => :ownable

  # 個人は名前をもつ
  # attr_accessor :name

  # 個人は貢献度の値をもつ
  # attr_accessor :contribution

  # 貢献度を計算する
  def calculate_contribution
    self.class.contributions[self.id]
  end

  # 他の経済主体に評価を与える
  def evaluate!(seller, amount)
    given_evaluations.create(:sellable => seller, :amount => amount)
  end

  # 他の経済主体への評価値を取得する
  def evaluation_to(seller)
    # p [self.id, seller.id, given_evaluations.to(seller)]
    given_evaluations.to(seller).amount # rescue nil
  end

  # 他の経済主体からの評価値を取得する
  def evaluation_from(buyer)
    earned_evaluations.from(buyer).amount # rescue nil
  end

  # 自己評価値を取得する
  def self_evaluation
    evaluation_to(self)
  end

  def self.ids
    pluck(:id).sort
  end
  
  def self.id_seq
    ids.each.with_index.inject({}) do |h, (person_id, i)|
      h[person_id] = i
      h
    end
  end

  # 貢献度の配列
  def self.contributions
    eigenvalues = Evaluation.person_matrix.eigensystem.eigenvalues
    ids.each.with_index.inject({}) do |h, (person_id, i)|
      h[person_id] = eigenvalues[i]
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
  def self.initialize_matrix!
    m = initialize_matrix
    Evaluation.delete_all
    all.each.with_index do |buyer, i|
      all.each.with_index do |seller, j|
        buyer.evaluate!(seller, m[i, j])
      end
    end
  end

  # マルコフ過程を用い貢献度を評価行列から計算し、各々のPersonにContributionを格納する
  def self.calculate_contributions
    # 評価行列を生成
    m = initialize_matrix
    
  end

end
