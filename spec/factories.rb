FactoryGirl.define do
  factory :user do
		name "user"
		uid 1
		provider "twitter"
	end

  factory :market do
		user
		name "market"
		people_count 3
		evaluation_parameter 100000
		initial_self_evaluation 20000
		natural_recovery_ratio 0.01
	end

  factory :market5, class: Market do
		user
		name "market"
		people_count 5
		evaluation_parameter 100000
		initial_self_evaluation 10000
		natural_recovery_ratio 0.01
	end

  factory :secsy_market, class: Market do
		user
		name "SECSY market"
		people_count 3
		evaluation_parameter 100000
		initial_self_evaluation 20000
		natural_recovery_ratio 0.01
    system "SECSY"
	end

  factory :person do
    market
    name "person"
  end

  factory :person5, class: Person do
    market5
    name "person"
  end

end

