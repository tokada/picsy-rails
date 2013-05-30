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

  # 個人は貢献度の値をもつ
end
