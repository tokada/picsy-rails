require 'spec_helper'

describe Evaluation do
  before do
    # テストケースの許容誤差
    @delta = 0.0001

    # 初期評価行列
    @expected_initial_matrix = Matrix[
      [0.0, 0.25, 0.25, 0.25, 0.25],
      [0.25, 0.0, 0.25, 0.25, 0.25],
      [0.25, 0.25, 0.0, 0.25, 0.25],
      [0.25, 0.25, 0.25, 0.0, 0.25],
      [0.25, 0.25, 0.25, 0.25, 0.0]
    ]

    # 「なめ敵」図4.4の評価行列
    @n44matrix = Matrix[
      [0.1 , 0.2 , 0.15, 0.3 , 0.25],
      [0.3 , 0.2 , 0.1 , 0.1 , 0.3 ],
      [0.3 , 0.0 , 0.15, 0.35, 0.2 ],
      [0.2 , 0.25, 0.3 , 0.2 , 0.05],
      [0.2 , 0.1 , 0.25, 0.3 , 0.15],
    ]
    # 「なめ敵」図4.4の貢献度ベクトル
    @n44expected  = Vector[1.0697, 0.7756, 0.9910, 1.2677, 0.8961]
    @n44expected_2 = Vector[1.1737, 0.7711, 0.9773, 1.1622, 0.9157]
    @n44expected_diff = [0.1040, -0.0045, -0.0136, -0.1055, 0.0196]
  end

  before(:each) do
    FactoryGirl.create_list(:person, 5)
    @person1 = Person.first
    @person2 = Person.first(2).last
  end

  describe ".natural_recovery!" do
    context "初期評価行列に自然回収を行った場合" do
      before do
        Person.initialize_matrix!
        @old_evaluations = Evaluation.person_matrix
        Evaluation.natural_recovery!(0.01)
        @new_evaluations = Evaluation.person_matrix
      end

      it "評価行列の値が変わること" do
        expect(@new_evaluations).not_to eq(@old_evaluations)
      end

      it "他者への評価値が減少すること" do
        expect(@new_evaluations[0, 1]).to be < @old_evaluations[0, 1]
      end

      it "自己評価値が増加すること" do
        expect(@new_evaluations[0, 0]).to be > @old_evaluations[0, 0]
      end
    end

    context "「なめ敵」図4.4の評価行列に自然回収を行った場合" do
      before do
        Person.initialize_matrix!(@n44matrix)
        @old_evaluations = Evaluation.person_matrix
        Evaluation.natural_recovery!(0.01)
        @new_evaluations = Evaluation.person_matrix
      end

      it "評価行列の値が変わること" do
        expect(@new_evaluations).not_to eq(@old_evaluations)
      end

      it "他者への評価値が減少すること" do
        expect(@new_evaluations[0, 1]).to be < @old_evaluations[0, 1]
      end

      it "自己評価値が増加すること" do
        expect(@new_evaluations[0, 0]).to be > @old_evaluations[0, 0]
      end
    end

  end

end
