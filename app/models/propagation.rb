class Propagation < ActiveRecord::Base
  belongs_to :trade
  belongs_to :actor_from
  belongs_to :actor_to
end
