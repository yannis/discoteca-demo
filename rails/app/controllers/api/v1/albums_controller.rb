class Api::V1::AlbumsController < ApplicationController
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
end