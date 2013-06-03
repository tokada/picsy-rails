load 'constant.rb'

module Picsy
module Kernel
class CurrencyNotFoundException < StandardError

  def initialize(currency_id)
    super("Currency [#{currency_id}] not found.")
  end

end
end
end
