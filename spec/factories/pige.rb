require 'factory_girl'
require 'faker'

FactoryGirl.define do
  sequence :name do |n|
    Faker::Name.name
  end

  factory :member do
    name
  end
end
