class AddManipulatorToComments < ActiveRecord::Migration[7.0]
  def change
    add_reference :comments, :com_manipulator, null: false, foreign_key: { to_table: :manipulators }
  end
end
