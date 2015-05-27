FactoryGirl.define do
  factory :artist do
    name {Faker::Name.name}
  end
end