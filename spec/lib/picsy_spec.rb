require 'spec_helper'
require 'picsy'

describe Picsy do
  before do
    # テストケースの許容誤差
    @delta = 0.0001

    5.times { FactoryGirl.create(:person) }
    # 初期評価行列
    @initial_matrix = Person.initialize_matrix

    # 「なめ敵」図4.4の評価行列
    @n44matrix = Matrix[
      [0.1 , 0.2 , 0.15, 0.3 , 0.25],
      [0.3 , 0.2 , 0.1 , 0.1 , 0.3 ],
      [0.3 , 0.0 , 0.15, 0.35, 0.2 ],
      [0.2 , 0.25, 0.3 , 0.2 , 0.05],
      [0.2 , 0.1 , 0.25, 0.3 , 0.15],
    ]
    # 「なめ敵」図4.4の貢献度ベクトル
    @n44expected = Vector[1.0697, 0.7756, 0.9910, 1.2677, 0.8961]
  end

  describe ".calculate_contribution_by_analysis" do
    context "5人の初期評価行列の場合" do
      before do
        @contributions = Picsy.calculate_contribution_by_analysis(@initial_matrix)
      end

      it "解析解を求める方法で、貢献度を評価行列から計算し、貢献度ベクトルを返すこと" do
        expect(@contributions).to eq(Vector[1.0, 1.0, 1.0, 1.0, 1.0])
      end
    end

    context "「なめ敵」図4.4の行列の場合" do
      before do
        @contributions = Picsy.calculate_contribution_by_analysis(@n44matrix)
      end

      it "解析解の貢献度を返すこと" do
        @contributions.each.with_index do |c, i|
          expect(c).to be_within(@delta).of(1.0) # TODO: 合ってるか不明。。
        end
      end
    end
  end

  describe ".calculate_contribution_by_markov" do
    context "5人の初期評価行列の場合" do
      before do
        @contributions = Picsy.calculate_contribution_by_markov(@initial_matrix)
      end

      it "マルコフ過程を用い貢献度を評価行列から計算し、貢献度ベクトルを返すこと" do
        expect(@contributions).to eq(Vector[1.0, 1.0, 1.0, 1.0, 1.0])
      end
    end

    context "「なめ敵」図4.4の行列の場合" do
      before do
        @contributions = Picsy.calculate_contribution_by_markov(@n44matrix)
      end

      it "図4.4の通りの貢献度を返すこと" do
        @contributions.each.with_index do |c, i|
          expect(c).to be_within(@delta).of(@n44expected[i])
        end
      end
    end
  end

end