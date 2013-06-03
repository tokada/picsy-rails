require 'spec_helper'
require 'picsy'

describe Picsy do
  describe ".calculate_contribution_by_markov" do
    context "初期評価行列の場合" do
      before do
        5.times { FactoryGirl.create(:person) }
        @matrix = Person.initialize_matrix
        @vector = Picsy.contributions(@matrix)
      end

      it "マルコフ過程を用い貢献度を評価行列から計算し、貢献度ベクトルを返すこと" do
        contributions = Picsy.calculate_contribution_by_markov(@matrix, @vector)
        expect(contributions).to eq(Vector[0.0625, 0.0625, 0.0625, 0.0625, -0.25])
      end
    end
  end
end
