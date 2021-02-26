FactoryBot.define do
  factory :passenger do
    association :flight

    name { FFaker::Name.name }
    weight { rand 90...250 }
  end
end
