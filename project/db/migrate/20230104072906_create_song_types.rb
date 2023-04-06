class CreateSongTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :song_types do |t|
      t.string :名称

      t.timestamps
    end
  end
end
