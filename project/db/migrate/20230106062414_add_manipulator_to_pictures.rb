class AddManipulatorToPictures < ActiveRecord::Migration[7.0]
  def change
    add_reference :pictures, :manipulator, foreign_key: true
  end
end
