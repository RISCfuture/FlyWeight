FactoryBot.define do
  factory :passenger do
    association :flight

    name { FFaker::Name.name }
    weight { rand 90...250 }
    bags_weight { FFaker::Boolean.maybe ? rand(5...50) : 0 }
  end
end
