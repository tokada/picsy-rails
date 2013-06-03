require 'matrix'

# PICSY計算ライブラリ

class Picsy
  DEFAULT_CONTRIBUTION = 1
  DEFAULT_CONSTRAINT = 0 # 新規加入時の予算制約
  DEFAULT_DELETE_PERSON_AMOUNT = 0.00001 # パーソンを削除するときの貢献度の閾値
  DEFAULT_MARKOV_STOP_VALUE = 0.0000000001 # すべてのパーソンがこの値よりも小さい変化だった場合に、マルコフ過程を終了させる。
  DEFAULT_MAX_MARKOV_PROCESS = 10000000 # マルコフ過程の最大の回数。

  # マルコフ過程を用い貢献度を評価行列から計算し、貢献度ベクトルを返す
  # @param mat doubleの二次元配列型の評価行列
  def self.calculate_contribution_by_markov(matrix, vector)
    size = matrix.column_size
    last_vec = vector
    new_contribution = []
    catch(:convergent) do
      DEFAULT_MAX_MARKOV_PROCESS.times do |i|
      new_vec  = matrix  * last_vec # 計算する(掛け算)
      vec_diff = new_vec - last_vec # 差分の確認
      size.times do |j|
        if vec_diff[j] > DEFAULT_MARKOV_STOP_VALUE
          #許容範囲内で収束していればVectorを更新させる。
          new_contribution = new_vec
          throw :convergent
        end
      end
      last_vec = new_vec
      end
    end
    new_contribution
  end

  # 貢献度ベクトルを評価行列から計算する
  def self.contributions(matrix)
    Vector[*matrix.eigensystem.eigenvalues]
  end

end
