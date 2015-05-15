gem "active_model_serializers", "0.9.3"
gem "rspec-rails", "3.2.1"
gem "factory_girl_rails", "4.5.0"
gem "guard", "2.12.5"
gem "guard-rspec", "4.5.0"
gem "guard-bundler", "2.1.0"
gem "rb-fsevent", "0.9.4"
gem "faker", "1.4.3"
gem "shoulda-matchers", "2.8.0", require: false

run 'bundle config --local PATH ~/railsapps/genevarb_discoteca/bundle'
run 'bundle install'

run 'mkdir config/initializers'

File.open("config/initializers/active_model_serializers.rb", "w") do |f|
  f.write %Q(ActiveModel::Serializer.setup do |config|
  config.embed = :ids
  config.embed_in_root = false
end)
end

run 'bundle exec guard init rspec'
run 'bundle exec guard init bundler'

run 'cp ../support/seeds.rb db/seeds.rb'

generate("rspec:install")

generate(:model, "artist name:string")
generate(:model, "album name:string issued_on:date artist:belongs_to artwork_url:string")

File.open("spec/models/artist_spec.rb", "r+") do |f|
  f.write %Q(require 'rails_helper'

RSpec.describe Artist, type: :model do
  it {is_expected.to validate_presence_of :name}
  it {is_expected.to validate_uniqueness_of :name}
  it {is_expected.to have_many(:albums).dependent(:destroy)}
end)
end

File.open("app/models/artist.rb", "r+") do |f|
  f.write %Q(class Artist < ActiveRecord::Base
  has_many :albums, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :name
end)
end

File.open("spec/models/album_spec.rb", "r+") do |f|
  f.write %Q(require 'rails_helper'

RSpec.describe Album, type: :model do
  it {is_expected.to belong_to :artist}
  it {is_expected.to validate_presence_of :name}
  it {is_expected.to validate_uniqueness_of(:name).scoped_to(:artist_id)}
end)
end

File.open("app/models/album.rb", "r+") do |f|
  f.write %Q(class Album < ActiveRecord::Base
  belongs_to :artist
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :artist_id
end)
end

File.open("spec/factories/artists.rb", "r+") do |f|
  f.write %Q(FactoryGirl.define do
  factory :artist do
    name {Faker::Name.name}
  end
end)
end

File.open("spec/factories/albums.rb", "r+") do |f|
  f.write %Q(FactoryGirl.define do
  factory :album do
    name {Faker::Name.name}
    issued_on {(1980..2000).to_a.sample}
    artwork_url {Faker::Company.logo}
    association :artist
  end
end)
end


generate(:serializer, "artist name:string")
generate(:serializer, "album name:string")


File.open("app/serializers/artist_serializer.rb", "r+") do |f|
  f.write %Q(class ArtistSerializer < ActiveModel::Serializer
  attributes :id, :name
  embed :ids
  has_many :albums
end)
end

File.open("app/serializers/album_serializer.rb", "r+") do |f|
  f.write %Q(class AlbumSerializer < ActiveModel::Serializer
  attributes :id, :name, :issued_on, :artwork_url, :artist_id
end)
end

generate(:controller, "Api::V1::Artists index show --skip-assets --skip-template-engine --skip-helper")
generate(:controller, "Api::V1::Albums index show --skip-assets --skip-template-engine --skip-helper")

File.open("spec/controllers/api/v1/artists_controller_spec.rb", "r+") do |f|
  f.write %Q(require 'rails_helper'

RSpec.describe Api::V1::ArtistsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      xhr :get, :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    let(:artist) {create :artist}
    it "returns http success" do
      xhr :get, :show, id: artist.to_param
      expect(response).to have_http_status(:success)
    end
  end
end)
end

File.open("app/controllers/api/v1/artists_controller.rb", "r+") do |f|
  f.write %Q(class Api::V1::ArtistsController < ApplicationController
  def index
    artists = Artist.all
    render json: artists, each_serializer: ArtistSerializer
  end

  def show
    artist = Artist.find(params[:id])
    render json: artist, serializer: ArtistSerializer
  end
end
  )
end

File.open("spec/controllers/api/v1/albums_controller_spec.rb", "r+") do |f|
  f.write %Q(require 'rails_helper'

RSpec.describe Api::V1::AlbumsController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      xhr :get, :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    let(:album) {create :album}
    it "returns http success" do
      xhr :get, :show, id: album.to_param
      expect(response).to have_http_status(:success)
    end
  end
end)
end

File.open("app/controllers/api/v1/albums_controller.rb", "r+") do |f|
  f.write %Q(class Api::V1::AlbumsController < ApplicationController
  def index
    albums = Album.all
    render json: albums, each_serializer: AlbumSerializer
  end

  def show
    album = Album.find(params[:id])
    render json: album, serializer: AlbumSerializer
  end
end
  )
end

inside app_name do
  rake "db:drop"
  rake "db:create"
  rake "db:migrate"
  rake "db:migrate", env: 'test'
  rake "db:seed"
end

File.open("config/routes.rb", "r+") do |f|
  f.write %Q(Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :artists, only: [:index, :show]
      resources :albums, only: [:index, :show]
    end
  end
end)
end
