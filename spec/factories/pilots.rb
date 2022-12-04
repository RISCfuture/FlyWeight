# frozen_string_literal: true

FactoryBot.define do
  factory :pilot do
    name { FFaker::Name.name }
    sequence(:email) { |i| FFaker::Internet.email("#{name.to_param}-#{i}") }
    password { FFaker::Internet.password(8) }
    password_confirmation { password }
  end
end
