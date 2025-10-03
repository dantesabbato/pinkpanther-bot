require 'factory_bot'

FactoryBot.define do
  factory :group do
    title { "Группа #{Faker::Number.number(digits: 3)}" }
    enabled { true }
  end
end