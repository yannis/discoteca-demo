require 'rails_helper'

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
      expect(response.body).to eql "{\"artist\":{\"id\":1,\"name\":\"#{artist.name}\",\"album_ids\":[]}}"
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
end