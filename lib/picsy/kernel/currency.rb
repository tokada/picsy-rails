load 'constant.rb'

module Picsy
module Kernel
class Currency
  @deleted_persons = [] # 削除された人のリスト
  @id # 貨幣ID

  @persons = []
  @algorithm_type = 1
  @sync_type = 0

  @max_markov_process = Constant::DEFAULT_MAX_MARKOV_PROCESS
  @markov_stop_value = Constant::DEFAULT_MARKOV_STOP_VALUE
  @delete_person_amount = Constant::DEFAULT_DELETE_PERSON_AMOUNT

  attr_accessor :deleted_persons, :id
  attr_accessor :persons, :algorithm_type, :sync_type
  attr_accessor :max_markov_process, :markov_stop_value, :delete_person_amount

  ANALYSIS = 0
  MARKOV = 1

  ALL_SYNC = 0
  CONTRIBUTION_ASYNC = 1
  ALL_ASYNC = 2

  # Currencyクラスのコンストラクタ
  # Personの初期化を行う。
  # @param id 貨幣 _id
  # @param person_num 人数
  def initialize(id, person_num)
    if person_num < 1
      raise IllegalArgumentException, "initial person number must be over 1"
    end

    @id = id

    # Personの追加
    person_num.times do |i|
      @persons << Person.new(i)
    end

    # Evaluationの初期化と追加、貢献度の初期化
    person_num.times do |i|
      evaluations = []
      target = @persons[i]
      person_num.times do |j|
        if i == j
          evaluations << Evaluation.new(target, @persons[j], 0)
        else
          evaluations << Evaluation.new(target, @persons[j], 1.0 / (person_num - 1))
        end
      end
      target.evaluations = evaluations
      target.contribution = Constant::DEFAULT_CONTRIBUTION
    end
  end

  def update_contribution
    case @algorithm_type
    when ANALYSIS
      calculate_contribution_by_analysis(get_double_matrix)
    when MARKOV
      calculate_contribution_by_markov(get_double_matrix, get_double_vector)
    end
  end

  def persons=(person_list)
    Assert.not_null(person_list, "person_list")
    @persons = person_list
  end

  # 解析解を求める方法で、貢献度を評価行列から計算し、各々のPersonにContributionを格納する
  # @param mat doubleの二次元配列型の評価行列
  def calculate_contribution_by_analysis(mat)
    size = mat.length
    Matrix mtx = Matrix.new(mat)
    # 固有ベクトル・固有値取得
    EigenvalueDecomposition eig = mtx.eig

    # 最大の固有ベクトルのインデックスを求める
    eig_d = eig.real_eigenvalues # 固有値実数部分取得
    double last_max_eig_d = 0
    int last_max_idx = 0
    eig_d.length.times do |k|
      if last_max_eig_d < eig_d[k]
        last_max_eig_d = eig_d[k]
        last_max_idx = k
      end
    end

    # 最大固有値に虚数部が出てないかをチェック
    double eig_imag_d = eig.get_imag_eigenvalues[last_max_idx]
    if Math.abs(eig_imag_d) > 0
      # FIXME: generate exception
      raise "last_max_idx is an imaginary number"
    end

    # 固有ベクトル取得
    Matrix eig_v = eig.v
    # 貢献度ベクトル取得
    contributions = eig_v.column_dimension

    double sum = 0
    size.times do |i|
      contributions[i] = Math.abs(eig_v.get(i, last_max_idx))
      sum = sum + contributions[i]
    end

    size.times do |i|
      contributions[i] = contributions[i] * size / sum
      @persons[i].contribution = contributions[i]
    end
  end

  # マルコフ過程を用い貢献度を評価行列から計算し、各々のPersonにContributionを格納する
  # @param mat doubleの二次元配列型の評価行列
  def calculate_contribution_by_markov(mat, vec)
    matrix = Matrix.new(mat)
    size = matrix.column_dimension
    vector = Matrix.new(vec)
    nf = NumberFormat.instance
    nf.maximum_fraction_digits = 10
    last_vec = vector
    is_convergent = false
    i = 0
    while (!is_convergent)
      #無限ループを防ぐ、回数制限
      if i > Constant::DEFAULT_MAX_MARKOV_PROCESS
        raise MarkovProcessIsNotConvergentException.new
      end
      #計算する(掛け算)
      new_vec = matrix.times(last_vec)
      #差分の確認
      dif = new_vec.minus(last_vec)
      is_convergent = true
      size.times do |j|
        if dif.get(j, 0) > Constant::DEFAULT_MARKOV_STOP_VALUE
          is_convergent = false
          break
        end
      end
      #許容範囲内で収束していればVectorを更新させる。
      if is_convergent
        #vectorを更新させる。
        size.times do |j|
          @persons.get(j).contribution = new_vec.get(j,0)
        end
      end
      #次回の準備
      i++
      last_vec = new_vec
      #puts i
    end
  end

  class MarkovProcessIsNotConvergentException < StandardError
    def initialize(msg = "Markov process is not convergent. Please use the Analysis method change settings")
      super(msg)
    end
  end
  
  # 自然回収を行う
  def natural_recovery(natural_recovery_ratio)
    Assert.greater_than(0,natural_recovery_ratio,"natural_recovery_ratio",false)
    Assert.smaller_than(1,natural_recovery_ratio,"natural_recovery_ratio",false)

    @persons.each do |target|
      if target.is_alive
        target.evaluations.each do |eva|
          eva.natural_recovery(natural_recovery_ratio)
        end
      end
    end

    update_contribution if sync_type == ALL_SYNC
  end

  def transact(buyer_id, seller_id, amount)
    #FIXME: 例外処理をすべき
    buyer = get_person(buyer_id)
    seller = get_person(seller_id)
    buyer.evaluation(buyer).add(-amount)
    buyer.evaluation(seller).add(amount)
    if sync_type == ALL_SYNC
      update_contribution
    end
  end

  def kill_person(person_id)
    get_person(person_id).kill
  end

  def ressurect_person(person_id)
    get_person(person_id).ressurect
  end

  # パーソンを削除する。貢献度の再計算を行ってから、利用することが推奨される。
  # 削除後に、貢献度の再計算が自動的に行われる。
  def delete_person!
    @persons.each do |target|
      if target.is_dead and person.contribution < Constant::DEFAULT_DELETE_PERSON_AMOUNT

        #personsから本人を削除
        @deleted_persons.add(person)
        @persons.remove(person)

        #他人のEvaluationsからの削除
        @persons.each do |p2|
          p2.del_evaluation(person)
        end
      end
    end

    update_contribution
  end

  def get_person(person_id)
    @persons.each do |person|
      return person if person.id == person_id
    end
    raise IllegalArgumentException,new("no such person whose _id is [#{person_id}] ")
  end

  # パーソンを追加する。自動的に(人数＋１)の番号を振る等の操作は行われない_id指定を必須とする。
  # このメソッドは最新の更新の貢献度を利用して計算するため、このメソッドが呼ばれる前には貢献度の計算を行う必要がある。
  # @param peid 追加するパーソンの_id
  # @throws Exception
  def add_person(person_id)
    Assert.greater_than(0,person_id,"person_id",true)
    # 新規加入者の作成（評価ベクトルも含む）
    evaluations = []
    penum = @persons.size #新規加入前の人数
    index = 0 #何番目に新規加入者をいれるべきか
    #新規加入者の初期化
    person = Person.new(person_id)

    #すでにパーソンがいてアカウントから削除されていた場合を確認する。
    @deleted_persons.each do |target|
      if (person_id == target.id)
        raise StandardError.new("The same id person existed, but was deleted.")
      end
    end

    #すでにパーソンが存在している(削除はされていない)かどうかを確認すると同時に、新規加入者の評価ベクトルをつくる
    @persons.each do |target|
      if (person_id == target.id)
        raise StandardError.new("The same id person exists.")
      end
      evaluations.add(
        Evaluation.new(
          person,
          target,
          target.contribution / penum))
      #ここで最新の貢献度が利用される
      index += 1
    end
    #自己評価をいれる
    evaluations.add(index, Evaluation.new(person, person, 0))
    #新規加入者の評価ベクトルを形成
    person.evaluations = evaluations

    # 既存の人の評価ベクトルの調整
    @persons.each do |target|
      target_evaluations = target.evaluations

      #既存の評価の定率縮退
      target_evaluations.each do |eva|
        newvalue = eva.amount * (penum - 1) / penum
        eva.value = newvalue
      end
      #新規加入者への挿入
      target_evaluations.add(
        index,
        Evaluation.new(target, person, 1 / penum))
    end

    #新規加入者のpersonsへの挿入
    @persons.add(index, person)
    if sync_type == ALL_SYNC
      update_contribution
    end

    # このメソッドが通すべきテストケースは以下の通り。
    #   peidがすでに存在する場合→例外
    #   peidが存在せず、0の場合→正常(削除がおわってから)
    #   peidが存在せず、前後の_idも存在しない場合→正常(削除がおわってから)
    #   peidが存在せず、penum+1の場合→正常
    #   peidが存在せず、penum+2の場合→正常
  end

  # double型の二次元配列の評価行列を返す。
  def get_double_matrix
    num = @persons.size
    mat = []
    num.times do |i|
      num.times do |j|
        mat[j] ||= []
        mat[j][i] = @persons.get(i).evaluations[j].amount
      end
    end
    return mat
  end

  # double型の貢献度ベクトルを返す。
  def get_double_vector
    num = @persons.size
    vec = []
    num.times do |i|
      vec[i] ||= []
      vec[i][0] = @persons[i].contribution
    end
    return vec
  end

  def algorithm_type=(type)
    Assert.greater_than(0,type,"algorithm type",true)
    Assert.smaller_than(1,type,"algorithm type",true)
    @algorithm_type = type
  end

  def persons
    @persons
  end

  def person_num
    @persons.size
  end

  def max_person_id
    @persons.get[persons.size() - 1].id
  end

  def evaluation(evaluator_id, evaluatee_id)
    evaluator = get_person(evaluator_id)
    evaluatee = get_person(evaluatee_id)
    return evaluator.evaluation(evaluatee).amount
  end
  
  def evaluations_from(evaluator_id)
    evaluations = get_person(evaluator_id).evaluations
    size = evaluations.size
    evaluation_data = EvaluationData.new(size)
    evaluations.each.with_index do |evaluation, i|
      evaluation_data[i] = EvaluationData.new(evaluation.evaluator.id,
                                              evaluation.evaluatee.id,
                                              evaluation.amount)
    end
    return evaluation_data
  end

  def evaluations_to(evaluatee_id)
    evaluatee = get_person(evaluatee_id)
    size = @persons.size()
    evaluation_data = EvaluationData.new(size)
    @persons.each.with_index do |person|
      Evaluation evaluation = person.evaluation(evaluatee)
      evaluation_data[i] = EvaluationData.new(evaluation.evaluator.id,
                                              evaluation.evaluatee.id,
                                              evaluation.amount)
    end
    return evaluation_data
  end
  
  def persons_info
    @persons.map do |person|
      PersonInfo.new(person)
    end
  end
  
  def person_info(id)
    PersonInfo.new(get_person(id))
  end
  
  def evaluation_price(evaluator_id, evaluatee_id, contribution_price)
    #精緻値を求める（収束させる）方法と近似値を求める（まわりの値から計算する）方法がある
    #精緻値を求める場合でも、近似値からスタートさせる
    #とりあえず近似値で実装しておきます。
    # TODO 数値計算による求解
    evaluator = get_person(evaluator_id)
    evaluatee = get_person(evaluatee_id)
    contribution_of_evaluator = evaluator.contribution
    total_evaluation_from_evaluator_to_others = 1 - evaluator.evaluation(evaluator).amount
    total_evaluation_from_evaluatee_to_others = 1 - evaluatee.evaluation(evaluatee).amount
    evaluation_from_evaluator_to_evaluatee = evaluator.evaluation(evaluatee).amount
    if contribution_price < 0
      raise IllegalArgumentException.new("contributionPrice is minus")
    end
    if contribution_price > evaluator.evaluation(evaluator).amount
      raise IllegalArgumentException.new("contributionPrice is over budget constraint")
    end
    return contribution_price * total_evaluation_from_evaluatee_to_others * total_evaluation_from_evaluator_to_others / (contribution_of_evaluator * (total_evaluation_from_evaluator_to_others + evaluation_from_evaluator_to_evaluatee) - contribution_price * total_evaluation_from_evaluatee_to_others)
  end

  def sync_type=(i)
    Assert.greater_than(0,i,"sync_type",true)
    Assert.smaller_than(1,i,"sync_type",true)
    @sync_type = i
  end

  def delete_person_amount=(d)
    Assert.greater_than(0,d,"delete_person_amount",false)
    @delete_person_amount = d
  end

  def markov_stop_value=(d)
    Assert.greater_than(0,d,"markov_stop_value",false)
    @markov_stop_value = d
  end

  def max_markov_process=(i)
    Assert.greater_than(0,i,"max_markov_process",false)
    @max_markov_process = i
  end
  
  def update_evaluation
  end

end
end
end
