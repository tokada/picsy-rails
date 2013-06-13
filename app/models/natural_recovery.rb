#
# 自然回収
#
class NaturalRecovery < ActiveRecord::Base
  belongs_to :market

  # 自然回収率
  attr_accessible :ratio

  def add(person, value)
    @hash_data ||= {}
    @hash_data[person.id] = value
  end

  before_save :update_data

  def update_data
    self.data = @hash_data.inspect
  end

  def read_data
    @hash_data = instance_eval data
  end

  def read_data_once
    @hash_data ||= read_data
  end

  def filled
    read_data_once
    market.people.map do|person|
      @hash_data[person.id]
    end
  end

  def filled_quantized(n=nil)
    n ||= (market.evaluation_parameter || 100000)
    filled.map do |q|
      q = (n <= 1 ? sprintf("%0.04f", q) : sprintf("%d", q))
      q == "0" ? "" : "+#{q}"
    end
  end

  def ratio_percent
    sprintf("%d%", ratio.to_f * 100)
  end
end
