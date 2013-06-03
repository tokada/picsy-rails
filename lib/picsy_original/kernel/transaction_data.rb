load 'constant.rb'

module Picsy
module Kernel
class TransactionData

  attr_accessor :evaluator_id, :evaluatee_id, :amount
  attr_accessor :date, :currency_log_id
  
  def initialize(evaluator_id, evaluatee_id, amount, date, currency_log_id)
    @evaluator_id = evaluator_id
    @evaluatee_id = evaluatee_id
    @amount = amount
    @date = date
    @currency_log_id = currency_log_id
  end

end
end
end
