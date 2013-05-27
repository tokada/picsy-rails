load 'constant.rb'

module Picsy
module Kernel
class Evaluation

  attr_accessor :evaluator, :evaluatee, :amount

  def initialize(evaluator, evaluatee, amount)
    @evaluator = evaluator
    @evaluatee = evaluatee
    @amount = amount
  end

  def add(value)
    newamount = amount + value
    if 1 < newamount || newamount < 0
      raise IllegalArgumentException.new("illegal evaluation range exception by add")
    end
    if evaluator.is_dead
      raise IllegalStateException.new("evaluator is dead: you cannot change value")
    end
    newamount
  end

  def times(value)
    newamount = amount * value
    if 1 < newamount || newamount < 0
      raise IllegalArgumentException.new("ilegal evaluation range exception by times")
    end
    if evaluator.is_dead
      raise IllegalStateException.new("evaluator is dead: you cannot change value")
    end
    newamount
  end

  def natural_recovery(natural_recovery_ratio)
    # ‘S•]‰¿‚©‚çˆê’è—¦‚ð’¥Žû
    times(1 - natural_recovery_ratio)
    # Ž©ŒÈ•]‰¿‚ÉŽ©‘R‰ñŽû—¦‚ðãæ‚¹
    if evaluatee.equals(evaluator)
      add((1-amount) * natural_recovery_ratio)
    end
  end

  def evaluatee=(actor)
    @evaluatee = actor
  end

  def evaluator=(actor)
    @evaluator = actor
  end

  def value=(value)
    @amount = value
  end


end
end
end
