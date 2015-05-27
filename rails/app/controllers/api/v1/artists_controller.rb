class Api::V1::ArtistsController < ApplicationController
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
    if @artist.update(sanitizer)
      render json: @artist, serializer: ArtistSerializer, status: 200
    else
      render json: {errors: @artist.errors}, status: :unprocessable_entity
    end
  end

  def destroy
    @artist = Artist.find(params[:id])
    render json: @artist.destroy
  end

  private

  def sanitizer
    params.require(:artist).permit(:name)
  end
end
