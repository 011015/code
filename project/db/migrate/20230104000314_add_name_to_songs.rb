class AddNameToSongs < ActiveRecord::Migration[7.0]
  def change
    add_column :songs, :名称, :string
  end
end
