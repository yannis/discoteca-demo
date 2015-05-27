require 'rails_helper'

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
      expect(response.body).to eql "{\"album\":{\"id\":1,\"name\":\"#{album.name}\",\"released_on\":\"#{album.released_on}\",\"artwork_url\":\"#{album.artwork_url}\",\"artist_id\":1}}"
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
end