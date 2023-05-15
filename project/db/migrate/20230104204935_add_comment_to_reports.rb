class AddCommentToReports < ActiveRecord::Migration[7.0]
  def change
    add_reference :reports, :comment, null: false, foreign_key: true
  end
end
