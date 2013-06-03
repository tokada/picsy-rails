load 'constant.rb'

module Picsy
module Kernel
class CurrencyInfo

  attr_accessor :id, :is_running, :person_num
  attr_accessor :algorithm_type, :sync_type
  attr_accessor :max_markov_process, :markov_stop_value, :delete_person_amount
  attr_accessor :natural_recovery_interval, :natural_recovery_ratio

  def initialize(currency, scheduler, is_running)
    @id = currency.id
    @algorithm_type = currency.algorithm_type
    @sync_type = currency.sync_type
    @max_markov_process = currency.max_markov_process
    @markov_stop_value = currency.markov_stop_value
    @delete_person_amount = currency.delete_person_amount
    @natural_recovery_interval = scheduler.natural_recovery_interval
    @natural_recovery_ratio = scheduler.natural_recovery_ratio
    @is_running = is_running.to_s
    @person_num = currency.person_num 
  end

end
end
end
