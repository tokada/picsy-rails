require "spec_helper"

describe Person do
  before(:each) do
    5.times { FactoryGirl.create(:people) }
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

  describe ".calculate_contributions" do
    it "マルコフ過程を用い貢献度を評価行列から計算し、各々のPersonにcontributionを格納すること" do
      p Person.calculate_contributions
    end
  end
end
