class Trade < ActiveRecord::Base
  belongs_to :buyable
  belongs_to :sellable
  belongs_to :item
end
