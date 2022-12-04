# frozen_string_literal: true

FactoryBot.define do
  factory :passenger do
    association :flight

    name { FFaker::Name.name }
    weight { rand 90...250 }
    bags_weight { FFaker::Boolean.maybe ? rand(5...50) : 0 }
    covid19_vaccine { FFaker::Boolean.maybe }
    covid19_test_negative { FFaker::Boolean.maybe }
    covid19_vaccine_booster { FFaker::Boolean.maybe }
  end
end
