Artist.destroy_all
10.times do
  if artist = Artist.create!(name: Faker::Name.name)
    p "Artist '#{artist.name}' created"
    3.times do
      album_name = Faker::Company.name
      if album = Album.create!(
        artist: artist,
        name: album_name,
        issued_on: Faker::Date.between(30.years.ago, 15.years.ago),
        artwork_url: "http://lorempixel.com/300/300/nightlife/#{album_name}/"
        # artwork_url: Faker::Company.logo
      )
        p "Album '#{album.name}' created"
      end
    end
  end
end
