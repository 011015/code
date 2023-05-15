class CreateSongs < ActiveRecord::Migration[7.0]
  def change
    create_table :songs do |t|
      t.string :演唱
      t.string :作词
      t.string :作曲

      t.timestamps
    end
  end
end
