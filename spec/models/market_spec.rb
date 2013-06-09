require 'spec_helper'

describe Market do
	describe "\#create" do
		before do
			@market = FactoryGirl.create(:market)
		end

		it "市場を作成すること" do
			expect(@market.user).not_to be_nil
			expect(@market.name).not_to be_nil
			expect(@market.evaluation_parameter).to be(100000)
			expect(@market.initial_self_evaluation).to be(20000)
			expect(@market.natural_recovery_rate).to be(1)
		end

		it "個人を作成すること" do
			expect(@market.people.reload.count).to eq(3)
			@market.people.each do |person|
				expect(person.contribution).to eq(1.0)
			end
		end

		it "評価を作成すること" do
			expect(@market.evaluations.reload.count).to eq(9)
			@market.evaluations.each do |ev|
				expect(ev.amount).to be > 0.0
			end
		end

		it "評価を作成すること" do
			expect(@market.matrix).to eq(
				Matrix[[0.2, 0.4, 0.4], [0.4, 0.2, 0.4], [0.4, 0.4, 0.2]]
			)
		end
	end
end
