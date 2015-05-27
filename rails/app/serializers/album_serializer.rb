class AlbumSerializer < ActiveModel::Serializer
  attributes :id, :name, :released_on, :artwork_url, :artist_id
end