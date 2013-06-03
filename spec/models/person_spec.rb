require "spec_helper"

describe Person do
  before(:each) do
    5.times { FactoryGirl.create(:person) }
    @person1 = Person.first
    @person2 = Person.first(2).last
  end

  describe "give_evaluation_to(seller, amount)" do
    before do
      Evaluation.delete_all
    end

    it "他の経済主体に評価を与えること" do
      @person1.evaluate!(@person2, 0.1)
      expect(@person1.evaluation_to(@person2)).to eq(0.1)
      expect(@person2.evaluation_from(@person1)).to eq(0.1)
    end
  end

  describe "calculate_evaluations" do
    context "初期評価行列の場合" do
      before do
        Person.initialize_matrix!
      end
      
      it "貢献度を計算すること" do
        # TODO: 正しいか不明
        expect(@person1.calculate_contribution).to eq(-0.25)
        expect(@person2.calculate_contribution).to eq(-0.25)
      end
    end
  end

  describe ".initialize_matrix" do
    context "メンバー数が5人の場合" do
      it "初期評価行列として、対角要素が0.0、非対角要素が0.25の行列を返すこと" do
        m = Person.initialize_matrix
        expect(m).to eq(
          Matrix[
            [0.0, 0.25, 0.25, 0.25, 0.25],
            [0.25, 0.0, 0.25, 0.25, 0.25],
            [0.25, 0.25, 0.0, 0.25, 0.25],
            [0.25, 0.25, 0.25, 0.0, 0.25],
            [0.25, 0.25, 0.25, 0.25, 0.0]
          ]
        )
      end
    end
  end

  describe ".initialize_matrix!" do
    before do
      Person.initialize_matrix!
    end

    it "初期評価行列をメンバ数の2乗のレコード数のデータとして保存すること" do
      expect(Evaluation.count).to eq(5*5)
    end

    it "各個人がメンバ全員分の評価値を保存すること" do
      expect(@person1.given_evaluations.count).to eq(5)
      expect(@person2.given_evaluations.count).to eq(5)
    end

    it "自己評価値を保存すること" do
      expect(@person1.self_evaluation).to eq(0.0)
      expect(@person2.self_evaluation).to eq(0.0)
    end
  end
  
  describe ".calculate_contributions" do
    context "初期評価行列に対して、人1が人2に0.1の評価を与えた場合" do
      before do
        Person.initialize_matrix!
      end

      it "マルコフ過程によって評価行列の値が変わること" do
        contributions = Person.calculate_contributions
      end
    end
  end
end
