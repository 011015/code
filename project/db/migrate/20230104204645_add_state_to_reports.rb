class AddStateToReports < ActiveRecord::Migration[7.0]
  def change
    add_column :reports, :状态, :string
  end
end
