class AddSongToPictures < ActiveRecord::Migration[7.0]
  def change
    add_reference :pictures, :song, foreign_key: true
  end
end
