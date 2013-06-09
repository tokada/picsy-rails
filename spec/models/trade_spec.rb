require 'spec_helper'

describe Trade do
	describe "\#propagations.filled_list" do
		before do
			@market = FactoryGirl.create(:market5)
			@people = @market.people
			@people[2].pay(@people[1], 0.00001)
			@trade = @market.trades.first
		end

		it "取引の伝播を穴埋めして返すこと" do
			expect(@trade.propagations(true).filled_list.size).to eq(5)
			expect(@trade.propagations.filled_list.first.id).to be_nil
		end
	end
end
