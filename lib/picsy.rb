require 'matrix'

# PICSY計算ライブラリ

class Picsy
  cattr_accessor :initial_contribution, :initial_constraint, :delete_person_amount,
                 :markov_stop_value, :max_markov_process

  @@initial_contribution = 1
  @@initial_constraint = 0 # 新規加入時の予算制約
  @@delete_person_amount = 0.00001 # パーソンを削除するときの貢献度の閾値
  @@markov_stop_value = 0.0000000001 # すべてのパーソンがこの値よりも小さい変化だった場合に、マルコフ過程を終了させる。
  @@max_markov_process = 10000 # マルコフ過程の最大の回数。

  # 解析解を求める方法で、貢献度を評価行列から計算し、貢献度ベクトルを返す
  def self.calculate_contribution_by_analysis(matrix)
    size = matrix.column_size
    eig = matrix.eigensystem # 固有ベクトル・固有値取得

    # 最大の固有ベクトルのインデックスを求める
    v = eig.eigenvalues
    eig_d = v.map(&:real) # 固有値実数部分取得
    max_eig_d = eig_d.max
    max_idx = eig_d.index(max_eig_d)

    # 最大固有値に虚数部が出てないかをチェック
    if v[max_idx].imaginary > 0
      raise "#{v[max_idx]} is an imaginary number"
    end

    # 固有ベクトル取得
    eig_v = eig.v
    # 貢献度ベクトル取得
    contributions = []

    size.times do |i|
      contributions[i] = eig_v[i, max_idx].abs
    end
    sum = contributions.sum

    size.times do |i|
      contributions[i] = contributions[i] * size / sum
    end
    Vector[*contributions]
  end

  # マルコフ過程を用い貢献度を評価行列から計算し、収束した貢献度ベクトルを返す
  def self.calculate_contribution_by_markov(matrix, last_c=nil)
    size = matrix.column_size
    # 貢献度ベクトルのデフォルトの初期値は人数分1が並ぶ配列とする
    last_c ||= Vector.elements([@@initial_contribution]*size)
    new_c = nil
    catch(:convergent) do
      @@max_markov_process.times do |i|
        # matrixをlast_cに掛け合わせる
        new_c = Vector.elements(matrix.transpose.to_a.map{|col|
          last_c.map.with_index {|c, j| c * col[j] }.sum
        })
        diff = new_c - last_c # 差分の確認
        #許容範囲内で収束していればVectorを更新させる。
        throw :convergent if diff.all?{|d| d.abs < @@markov_stop_value }
        last_c = new_c
      end
    end
    new_c
  end

end
