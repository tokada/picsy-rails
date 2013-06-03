load 'constant.rb'

module Picsy
module Kernel
class EvaluationData

  attr_accessor :evaluator_id, :evaluatee_id, :amount
  
  def initialize(evaluator_id, evaluatee_id, value)
    @evaluator_id = evaluator_id
    @evaluatee_id = evaluatee_id
    @amount = value
  end

end
end
end
