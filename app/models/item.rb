# 商品／Item
# 
# マーケットで取引される財。ラーメン取引シナリオでいえば、ラーメン・メン（麺）・ナルト・ショーユなど。
# 消費財・中間財・生産財の3種が存在する。質と量という二つの属性を持つ。
# 質は、その財を消費したときに得られる効用を表し、
# 消費財の場合はアクターに効用を与え、
# 生産財・中間財の場合は、生産された財に効用を追加する。
#
class Item < ActiveRecord::Base
  # 商品は経済主体により所有される
  # an item is owned by an actor (person/company)
  belongs_to :ownable, :polymorphic => true
end
