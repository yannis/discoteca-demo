10.times do
  if artist = Artist.create!(name: Faker::Name.name)
    p "Artist '#{artist.name}' created"
    3.times do
      if album = Album.create!(
        artist: artist,
        name: Faker::Company.name,
        issued_on: (1980..2000).to_a.sample,
        artwork_url: Faker::Company.logo
      )
        p "Album '#{album.name}' created"
      end
    end
  end
end
