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
      expect(@market.natural_recovery_ratio_percent).to be(1)
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

  describe '市場がひとつの場合' do

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
      @market = FactoryGirl.create(:market5)
      FactoryGirl.create_list(:person, 5)
      @person1 = Person.first
      @person2 = Person.first(2).last
    end

    describe ".initialize_matrix" do
      context "メンバー数が5人の場合" do
        it "初期評価行列として、対角要素が0.0、非対角要素が0.25の行列を返すこと" do
          m = @market.initialize_matrix
          expect(m).to eq(@expected_initial_matrix)
        end
      end
    end

    describe ".initialize_matrix!" do
      context "評価行列を与えない場合" do
        before do
          @market.initialize_matrix!
        end

        it "初期評価行列をメンバ数の2乗のレコード数のデータとして保存すること" do
          expect(@market.evaluations.count).to eq(5*5)
        end

        it "各個人がメンバ全員分の評価値を保存すること" do
          @market.people.each do |person|
            expect(person.given_evaluations.count).to eq(5)
          end
        end

        it "自己評価値を保存すること" do
          @market.people.each do |person|
            expect(person.self_evaluation).to eq(0.0)
          end
        end

        it "他人への評価値を保存すること" do
          @market.people.each do |person1|
            @market.people.each do |person2|
              if person1 != person2
                expect(person1.evaluation_to(person2)).to eq(0.25)
              end
            end
          end
        end
      end

      context "「なめ敵」図4.4の評価行列を与えた場合" do
        before do
          @market.initialize_matrix!(0.0, @n44matrix)
        end

        it "初期評価行列をメンバ数の2乗のレコード数のデータとして保存すること" do
          expect(@market.evaluations.count).to eq(5*5)
        end

        it "各個人がメンバ全員分の評価値を保存すること" do
          @market.people.each do |person|
            expect(person.given_evaluations.count).to eq(5)
          end
        end

        it "自己評価値を保存すること" do
          expect(@market.people[0].self_evaluation).to eq(0.1)
          expect(@market.people[1].self_evaluation).to eq(0.2)
        end

        it "他人への評価値を保存すること" do
          expect(@person1.evaluation_to(@person2)).to eq(0.2)
          expect(@person2.evaluation_to(@person1)).to eq(0.3)
        end
      end
    end
    
    describe ".contributions" do
      context "初期評価行列の場合" do
        before do
          @market.initialize_matrix!
        end

        it "貢献度の配列を取得すること" do
          expect(@market.contributions).to eq([1.0, 1.0, 1.0, 1.0, 1.0])
        end
      end

      context "「なめ敵」図4.4の評価行列の場合" do
        before do
          @market.initialize_matrix!(0.0, @n44matrix)
        end

        it "貢献度の配列を取得すること" do
          @n44expected.each.with_index do |expected, i|
            expect(@market.contributions[i]).to be_within(@delta).of(expected)
          end
        end
      end
    end

    describe "\#trade(buyer, seller, amount)" do
      context "「なめ敵」図4.4のシナリオの場合" do
        before do
          @market.initialize_matrix!(0.0, @n44matrix)
          @market.trade(@market.people[3], @market.people[0], 0.1)
          #@market.people.reload
          @contributions = @market.contributions
          @trade1 = @market.people[3].given_trades.first
        end

        it "全員の貢献度が変化すること" do
          @n44expected_2.each.with_index do |expected, i|
            expect(@contributions[i]).to be_within(@delta).of(expected)
          end
        end

        it "購入者=4、販売者=1、取引額0.1の取引履歴が記録されること" do
          expect(@market.people[3].given_trades.count).to eq(1)
          expect(@trade1.buyable).to eq(@market.people[3])
          expect(@trade1.sellable).to eq(@market.people[0])
          expect(@trade1.amount).to eq(0.1)
        end

        it "貢献度の伝播履歴が記録されること" do
          expect(@trade1.propagations.count).to eq(5)
          @trade1.propagations.pluck(:amount).reverse.each.with_index do |actual, i|
            expect(actual).to be_within(@delta).of(@n44expected_diff[i])
          end
        end
      end
    end

  end # of describe '市場がひとつの場合' do
end
