# Install the required gem
gem "active_model_serializers", "0.9.3"
# rack-cors allows rack-based applications to make cross domain AJAX calls without using workarounds such as JSONP
gem 'rack-cors', require: 'rack/cors'
gem_group :development, :test do
  gem "rspec-rails", "3.2.1"
end
gem_group :test do
  gem "factory_girl_rails", "4.5.0"
  gem "faker", "1.4.3"
  gem "shoulda-matchers", "2.8.0", require: false
end
run 'bundle config --local PATH ~/railsapps/discoteca/bundle'
run 'bundle install'

# basic settings for active_model_serializers
File.open("config/initializers/active_model_serializers.rb", "w") do |f|
  f.write %Q(ActiveModel::Serializer.setup do |config|
  config.embed = :ids
  config.embed_in_root = false
end)
end

line = 'config.active_record.raise_in_transactional_callbacks = true'
gsub_file 'config/application.rb', /(#{Regexp.escape(line)})/mi do
|match|
  %Q(#{match}

    config.action_dispatch.default_headers = {
      'Access-Control-Allow-Origin' => 'http://localhost:4200'
    })
end

run 'cp ../support/seeds.rb db/seeds.rb'

generate("rspec:install")

generate(:model, "artist name:string")
generate(:model, "album name:string released_on:date artist:belongs_to artwork_url:string")


line1 = "require 'rspec/rails'"
line2 = 'config.fixture_path = "#{::Rails.root}/spec/fixtures"'
gsub_file 'spec/rails_helper.rb', /(#{Regexp.escape(line1)})/mi do
|match|
  %Q(#{match}
require 'shoulda/matchers')
end
gsub_file 'spec/rails_helper.rb', /(#{Regexp.escape(line2)})/mi do
|match|
  %Q(#{match}
config.include FactoryGirl::Syntax::Methods)
end


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
    released_on {30.years.ago.to_date}
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
  has_many :albums
end)
end

File.open("app/serializers/album_serializer.rb", "r+") do |f|
  f.write %Q(class AlbumSerializer < ActiveModel::Serializer
  attributes :id, :name, :released_on, :artwork_url, :artist_id
end)
end

generate(:controller, "Api::V1::Artists index show create update destroy --skip-assets --skip-template-engine --skip-helper")
generate(:controller, "Api::V1::Albums index show create update destroy --skip-assets --skip-template-engine --skip-helper")
generate(:controller, "Api::Csrf index --skip-assets --skip-template-engine --skip-helper")

File.open("spec/controllers/api/v1/artists_controller_spec.rb", "r+") do |f|
  f.write %Q(require 'rails_helper'

RSpec.describe Api::V1::ArtistsController, type: :controller do

  let!(:artist) {create :artist}

  describe "GET #index" do
    before {
      xhr :get, :index
    }
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    it "assigns [artist] to @artists" do
      expect(assigns(:artists)).to match_array [artist]
    end
  end

  describe "GET #show" do
    let(:artist) {create :artist}
    before {xhr :get, :show, id: artist.to_param}
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    it "returns serialized artist" do
      expect(response.body).to eql ")+ '{\"artist\":{\"id\":1,\"name\":\"#{artist.name}\",\"album_ids\":[]}}'+%Q("
    end
    it "assigns artist to @artist" do
      expect(assigns(:artist)).to eql artist
    end
  end

  describe "GET 'create'", :focus do
    it "returns http success" do
      xhr :get, 'create', format: :json, artist: {name: "a new artist"}
      expect(response).to be_success
    end

    it {
      expect{
      xhr :get, 'create', format: :json, artist: {name: "a new artist"}
      }.to change{Artist.count}.by(+1)
    }
  end

  describe "PUT 'update'" do
    before {
      xhr :put, 'update', id: artist.id, artist: {name: "updated name"}, format: :json
    }
    it {expect(response).to be_success}
    it {expect(artist.reload.name).to eql "updated name"}
    it "assigns artist to @artist" do
      expect(assigns(:artist)).to eql artist
    end
  end

  describe "DELETE 'destroy'" do
    it "returns http success" do
      xhr :delete, 'destroy', id: artist.id
      expect(response).to be_success
    end

    it "assigns artist to @artist" do
      xhr :delete, 'destroy', id: artist.id
      expect(assigns(:artist)).to eql artist
    end

    it {
      expect{
        xhr :delete, 'destroy', id: artist.id
      }.to change{Artist.count}.by(-1)
    }
  end
end)
end

File.open("app/controllers/api/v1/artists_controller.rb", "r+") do |f|
  f.write %Q(class Api::V1::ArtistsController < ApplicationController
  def index
    @artists = Artist.includes(:albums)
    render json: @artists, each_serializer: ArtistSerializer
  end

  def show
    @artist = Artist.find(params[:id])
    render json: @artist, serializer: ArtistSerializer
  end

  def create
    @artist = Artist.new sanitizer
    if @artist.save
      render json: @artist, serializer: ArtistSerializer, status: :created
    else
      render json: {errors: @artist.errors}, status: :unprocessable_entity
    end
  end

  def update
    @artist = Artist.find(params[:id])
    @artist.update_attributes sanitizer
    render json: @artist
  end

  def destroy
    @artist = Artist.find(params[:id])
    render json: @artist.destroy
  end

  private

  def sanitizer
    params.require(:artist).permit(:name, :released_on, :artist_id, :artwork_url)
  end
end)
end

File.open("spec/controllers/api/v1/albums_controller_spec.rb", "r+") do |f|
  f.write %Q(require 'rails_helper'

RSpec.describe Api::V1::AlbumsController, type: :controller do

  let(:artist) {create :artist}
  let!(:album) {create :album, artist: artist}

  describe "GET #index" do
    before {
      xhr :get, :index
    }
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    it "assigns [album] to @albums" do
      expect(assigns(:albums)).to match_array [album]
    end
  end

  describe "GET #show" do
    let(:album) {create :album}
    before {xhr :get, :show, id: album.to_param}
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end
    it "returns serialized album" do
      expect(response.body).to eql ")+'{\"album\":{\"id\":1,\"name\":\"#{album.name}\",\"released_on\":\"#{album.released_on}\",\"artwork_url\":\"#{album.artwork_url}\",\"artist_id\":1}}"'+%Q(
    end
    it "assigns album to @album" do
      expect(assigns(:album)).to eql album
    end
  end

  describe "GET 'create'", :focus do
    it "returns http success" do
      xhr :get, 'create', format: :json, album: {name: "a new album", released_on: 20.years.ago, artist_id: artist.to_param}
      expect(response).to be_success
    end

    it {
      expect{
      xhr :get, 'create', format: :json, album: {name: "a new album", released_on: 20.years.ago, artist_id: artist.to_param}
      }.to change{Album.count}.by(+1)
    }
  end

  describe "PUT 'update'" do
    before {
      xhr :put, 'update', id: album.id, album: {name: "updated name"}, format: :json
    }
    it {expect(response).to be_success}
    it {expect(album.reload.name).to eql "updated name"}
    it "assigns album to @album" do
      expect(assigns(:album)).to eql album
    end
  end

  describe "DELETE 'destroy'" do
    it "returns http success" do
      xhr :delete, 'destroy', id: album.id
      expect(response).to be_success
    end

    it "assigns album to @album" do
      xhr :delete, 'destroy', id: album.id
      expect(assigns(:album)).to eql album
    end

    it {
      expect{
        xhr :delete, 'destroy', id: album.id
      }.to change{Album.count}.by(-1)
    }
  end
end)
end

File.open("app/controllers/api/v1/albums_controller.rb", "r+") do |f|
  f.write %Q(class Api::V1::AlbumsController < ApplicationController
  def index
    @albums = Album.all
    render json: @albums, each_serializer: AlbumSerializer
  end

  def show
    @album = Album.find(params[:id])
    render json: @album, serializer: AlbumSerializer
  end

  def create
    @album = Album.new sanitizer
    if @album.save
      render json: @album, serializer: AlbumSerializer, status: :created
    else
      render json: {errors: @album.errors}, status: :unprocessable_entity
    end
  end

  def update
    @album = Album.find(params[:id])
    @album.update_attributes sanitizer
    render json: @album
  end

  def destroy
    @album = Album.find(params[:id])
    render json: @album.destroy
  end

  private

  def sanitizer
    params.require(:album).permit(:name, :released_on, :artist_id, :artwork_url)
  end
end)
end


File.open("spec/controllers/api/csrf_controller_spec.rb", "w") do |f|
  f.write %Q(require 'rails_helper'

RSpec.describe Api::CsrfController, type: :controller do

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
)
end

File.open("app/controllers/api/csrf_controller.rb", "w") do |f|
  f.write %Q(class Api::CsrfController < ApplicationController

  def index
    render json: { request_forgery_protection_token => form_authenticity_token }.to_json
  end
end
)
end

run "rm config/routes.rb"
File.open("config/routes.rb", "w") do |f|
  f.write %Q(Rails.application.routes.draw do
  namespace :api do
    get :csrf, to: 'csrf#index'
    namespace :v1 do
      resources :artists, only: [:index, :show, :create, :update, :destroy]
      resources :albums, only: [:index, :show, :create, :update, :destroy]
    end
  end
end)
end

inside app_name do
  rake "db:drop"
  rake "db:create"
  rake "db:migrate"
  rake "db:migrate", env: 'test'
  rake "db:seed"
end



def gsub_file(path, regexp, *args, &block)
  content = File.read(path).gsub(regexp, *args, &block)
  File.open(path, 'wb') { |file| file.write(content) }
end
