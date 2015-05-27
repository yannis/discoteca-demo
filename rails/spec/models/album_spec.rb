require 'rails_helper'

RSpec.describe Album, type: :model do
  it {is_expected.to belong_to :artist}
  it {is_expected.to validate_presence_of :name}
  it {is_expected.to validate_uniqueness_of(:name).scoped_to(:artist_id)}
end