class Artist < ActiveRecord::Base
  has_many :albums, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name
end
