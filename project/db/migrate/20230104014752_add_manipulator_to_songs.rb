class AddManipulatorToSongs < ActiveRecord::Migration[7.0]
  def change
    add_reference :songs, :manipulator, null: false, foreign_key: true
  end
end
