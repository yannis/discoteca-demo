class CreateAlbums < ActiveRecord::Migration
  def change
    create_table :albums do |t|
      t.string :name
      t.date :released_on
      t.belongs_to :artist, index: true, foreign_key: true
      t.string :artwork_url

      t.timestamps null: false
    end
  end
end
