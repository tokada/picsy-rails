require "spec_helper"

describe Person do
  before do
    @market = FactoryGirl.create(:market5)
    FactoryGirl.create_list(:person, 5)
    @person1 = Person.first
    @person2 = Person.first(2).last
  end

  describe "\#evaluate!(seller, amount)" do
    before do
      Evaluation.delete_all
    end

    it "他の経済主体に評価を与えること" do
      @person1.evaluate!(@person2, 0.1)
      expect(@person1.evaluation_to(@person2)).to eq(0.1)
      expect(@person2.evaluation_from(@person1)).to eq(0.1)
    end
  end

end
