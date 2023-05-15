class AddManipulatorToReports < ActiveRecord::Migration[7.0]
  def change
    add_reference :reports, :manipulator, null: false, foreign_key: true
  end
end
