
# @author Kazutoshi Ono<ono@appresso.com>
class CurrencyLog < Log
  #  貨幣管理系インターフェース
  UPDATE_CONTRIBUTION = 2
  UPDATE_EVALUATION = 3
  SAVE_CURRENCY_DATA = 4
  #  貨幣設定系インターフェース
  SET_SYNC_TYPE = 100
  SET_NATURAL_RECOVERY_INTERVAL = 101
  SET_NATURAL_RECOVERY_RATIO = 102
  SET_ALGORITHM_TYPE = 103
  SET_DELETE_PERSON_AMOUNT = 104
  SET_MARKOV_STOP_VALUE = 105
  SET_MAX_MARKOV_PROCESS = 106
  #  貨幣操作系インターフェース
  ADD_PERSON = 10000
  KILL_PERSON = 10001
  RESURRECT_PERSON = 10002
  DELETE_PERSON = 10003
  TRANSACT = 10004
  NATURAL_RECOVERY = 10005

  attr_accessor :currency_id
  attr_accessor :to
  attr_accessor :amount
  attr_accessor :comment

  def initialize(currency_id, event_id)
    initialize(currency_id, event_id, "")
  end

  def initialize(currency_id, event_id, subject)
    initialize(currency_id, event_id, subject, 0, 0, "")
  end

  def initialize(currency_id, event_id, subject, option)
    initialize(currency_id, event_id, subject, option, 0, "")
  end

  def initialize(currency_id, event_id, subject, to, amount, comment)
    super(event_id, subject)
    self.currency_id = currency_id
    self.to = to
    self.amount = amount
    self.comment = comment
  end
end
