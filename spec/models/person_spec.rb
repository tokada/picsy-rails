require "spec_helper"

describe Person do
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

  describe '市場がひとつの場合' do

    before(:each) do
      @market = FactoryGirl.create(:market5)
      FactoryGirl.create_list(:person, 5)
      @person1 = Person.first
      @person2 = Person.first(2).last
    end

    describe "初期データについて" do
      it "市場の参加者が5人いること" do
        expect(@market.people.count).to eq(5)
      end

      it "市場の参加者全員が貢献度1.0であること" do
        @market.people.each do |person|
          expect(person.contribution).to eq(1.0)
        end
      end
    end

    describe "\#pay(seller, amount)" do
      context "「なめ敵」図4.4のシナリオの場合" do
        before do
          @market.initialize_matrix!(0.0, @n44matrix)
          people = Person.all
          @person1 = people[0]
          @person2 = people[1]
          @person3 = people[2]
          @person4 = people[3]
          @person5 = people[4]
          @person4.pay(@person1, 0.1)
          @contributions = @market.contributions
          @trade1 = @person4.given_trades.first
        end

        it "全員の貢献度が変化すること" do
          @n44expected_2.each.with_index do |expected, i|
            expect(@contributions[i]).to be_within(@delta).of(expected)
          end
        end

        it "購入者=4、販売者=1、取引額0.1の取引履歴が記録されること" do
          expect(@person4.given_trades.count).to eq(1)
          expect(@trade1.buyable).to eq(@person4)
          expect(@trade1.sellable).to eq(@person1)
          expect(@trade1.amount).to eq(0.1)
        end

        it "貢献度の伝播履歴が記録されること" do
          expect(@trade1.propagations.count).to eq(5)
          @trade1.propagations.pluck(:amount).each.with_index do |actual, i|
            expect(actual).to be_within(@delta).of(@n44expected_diff[i])
          end
          expect(@trade1.propagations.pluck(:evaluatable_id)).to eq(Person.pluck(:id))
        end
      end
    end

    describe "\#earn(buyer, amount)" do
      context "「なめ敵」図4.4のシナリオの場合" do
        before do
          Person.initialize_matrix!(@n44matrix)
          people = Person.all
          @person1 = people[0]
          @person2 = people[1]
          @person3 = people[2]
          @person4 = people[3]
          @person5 = people[4]
          @person1.earn(@person4, 0.1)
          @contributions = Person.contributions
          @trade1 = @person4.given_trades.first
        end

        it "全員の貢献度が変化すること" do
          @n44expected_2.each.with_index do |expected, i|
            expect(@contributions[i]).to be_within(@delta).of(expected)
          end
        end

        it "購入者=4、販売者=1、取引額0.1の取引履歴が記録されること" do
          expect(@person4.given_trades.count).to eq(1)
          expect(@trade1.buyable).to eq(@person4)
          expect(@trade1.sellable).to eq(@person1)
          expect(@trade1.amount).to eq(0.1)
        end

        it "貢献度の伝播履歴が記録されること" do
          expect(@trade1.propagations.count).to eq(5)
          @trade1.propagations.pluck(:amount).each.with_index do |actual, i|
            expect(actual).to be_within(@delta).of(@n44expected_diff[i])
          end
          expect(@trade1.propagations.pluck(:evaluatable_id)).to eq(Person.pluck(:id))
        end
      end
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

  end # of describe '市場がひとつの場合' do

end
