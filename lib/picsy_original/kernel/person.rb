load 'constant.rb'

module Picsy
module Kernel
class Person

  ALIVE = 0 # 生きている
  DEAD = 1 # 死亡
  DELETED = 2 # アカウントから削除。

  attr_accessor :id, :evaluations, :contribution, :status

  @evaluations = []
  @contribution = Constant::DEFAULT_CONTRIBUTION
  @status=ALIVE
  
  def initialize(id)
    @id = id
  end
  
  def evaluation(target)
    evaluations.find do |evaluation|
      evaluation.evaluatee == target
    end
  end
  
  def kill! # 例外処理
    if status == ALIVE
      status = DEAD
    else
      raise IllegalStateException.new("person["+ID+"] is not alive")
    end
  end
  
  def ressurect! # 例外処理
    if status == DEAD
      status = ALIVE
    else
      raise IllegalStateException.new("person["+ID+"] is not dead")
    end
  end
  
  def delete! # 例外処理
    if status == DEAD
      status = DELETED
    end
    evaluations = null
    contribution = 0
  end

  def alive?
    status == ALIVE
  end

  def dead?
    status == DEAD
  end
  
  def deleted?
    status == DELETED
  end

  def status=(status)
    @status = status
  end

  def contribution=(value)
    @contribution = value
  end

  def evaluations=(list)
    @evaluations = list
  end

  def id=(id)
    @id = id
  end
  
  def del_evaluation!(target)
    @evaluations.remove(evaluation(target))
  end

end
end
end
