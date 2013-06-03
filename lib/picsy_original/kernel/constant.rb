module Picsy
module Kernel
module Constant
  DEFAULT_CONTRIBUTION = 1
  DEFAULT_CONSTRAINT = 0 # 新規加入時の予算制約
  DEFAULT_DELETE_PERSON_AMOUNT = 0.00001 # パーソンを削除するときの貢献度の閾値
  DEFAULT_MARKOV_STOP_VALUE = 0.0000000001 # すべてのパーソンがこの値よりも小さい変化だった場合に、マルコフ過程を終了させる。
  DEFAULT_MAX_MARKOV_PROCESS = 10000000 # マルコフ過程の最大の回数。
end
end
end
