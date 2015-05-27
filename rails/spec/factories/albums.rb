FactoryGirl.define do
  factory :album do
    name {Faker::Name.name}
    released_on {30.years.ago.to_date}
    artwork_url {Faker::Company.logo}
    association :artist
  end
end