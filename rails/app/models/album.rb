class Album < ActiveRecord::Base
  belongs_to :artist
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :artist_id
end