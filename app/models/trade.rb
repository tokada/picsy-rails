# 取引／Trade
#
# 経済主体Aと経済主体Bとの間で、商品と評価を交換すること。
#
class Trade < ActiveRecord::Base
  # 経済主体は商品を買い、評価を売主に与える
  # an actor (person/company) buys an item from a certain actor as a trade
  belongs_to :buyable, :polymorphic => true

  # 経済主体は商品を売り、評価を買主からもらう
  # an actor (person/company) sells an item to a certain actor as a trade
  belongs_to :sellable, :polymorphic => true

  # 商品は複数の取引履歴をもつ
  # an item has many trades
  belongs_to :item
end
