class CreateManipulators < ActiveRecord::Migration[7.0]
  def change
    create_table :manipulators do |t|
      t.string :名称
      t.string :密码
      t.string :类型

      t.timestamps
    end
  end
end
