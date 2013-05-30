# 個人／Person
#
# 伝播投資貨幣を使用している個人。
#
class Person < ActiveRecord::Base
  # 個人は他の経済主体に評価を与える
  # a person gives evaluations to whom he/she buys an item from
  has_many :given_evaluations  , :as => :buyable  , :class_name => 'Evaluation'

  # 個人は他の経済主体から評価を与えられる
  # a person earns evaluations from whom he/she sells an item to
  has_many :earned_evaluations , :as => :sellable , :class_name => 'Evaluation'

  # 個人は他の経済主体から商品を買い、その売主に評価を与える取引を行う
  # a person buys an item as a trade
  has_many :given_trades       , :as => :buyable  , :class_name => 'Trade'

  # 個人は他の経済主体に商品を売り、その買主から評価をもらう取引を行う
  # a person sells an item as a trade
  has_many :earned_trades      , :as => :sellable , :class_name => 'Trade'

  # 個人は商品を所有する
  # a person owns many items
  has_many :items              , :as => :ownable
end
