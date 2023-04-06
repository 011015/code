class AddSongTypesToSongs < ActiveRecord::Migration[7.0]
  def change
    add_reference :songs, :song_type, foreign_key: true
  end
end
