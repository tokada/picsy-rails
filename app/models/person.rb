require 'matrix'

# 個人／Person
#
# 伝播投資貨幣を使用している個人。
#
class Person < ActiveRecord::Base
  # 個人は他の経済主体に評価を与える
  has_many :given_evaluations  , :as => :buyable  , :class_name => 'Evaluation'

  # 個人は他の経済主体から評価を与えられる
  has_many :earned_evaluations , :as => :sellable , :class_name => 'Evaluation'

  # 個人は取引時に他の経済主体から商品を買い、その売主に評価を与える
  has_many :given_trades       , :as => :buyable  , :class_name => 'Trade'

  # 個人は取引時に他の経済主体に商品を売り、その買主から評価をもらう
  has_many :earned_trades      , :as => :sellable , :class_name => 'Trade'

  # 個人は商品を所有する
  has_many :items              , :as => :ownable

  # 個人は名前をもつ
  # attr_accessor :name

  # 個人は貢献度の値をもつ
  # attr_accessor :contribution

  # 初期評価行列を生成する
  def self.initialize_matrix
    size = count
    v = (1.0 / (size - 1))
    # 対角要素は0.0、非対角要素は1.0を評価対象数で配分したものとする
    Matrix.build(size, size) {|r, c| r == c ? 0.0 : v }
  end

  # マルコフ過程を用い貢献度を評価行列から計算し、各々のPersonにContributionを格納する
  def self.calculate_contributions
    # 評価行列を生成
    m = initialize_matrix
    
  end

end
