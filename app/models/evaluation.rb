class Evaluation < ActiveRecord::Base
  belongs_to :buyable
  belongs_to :sellable
end
