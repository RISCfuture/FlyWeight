# frozen_string_literal: true

FactoryBot.define do
  factory :flight do
    association :pilot

    description { FFaker::BaconIpsum.sentence(3) }
    date { rand(10).days.from_now.to_date }
  end
end
