FactoryGirl.define do
  sequence :person_names do |n|
    "p_#{n}"
  end

  factory :people, class: Person do
    name { FactoryGirl.generate(:person_names) }
  end
end
