class CreateNotices < ActiveRecord::Migration[7.0]
  def change
    create_table :notices do |t|
      t.string :类型
      t.string :wh状态
      t.string :ma状态
      t.string :内容
      t.string :原因
      t.references :whistleblower, null: false, foreign_key: { to_table: :manipulators }
      t.references :manipulator, null: false, foreign_key: true

      t.timestamps
    end
  end
end
