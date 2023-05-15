# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_02_04_094320) do
  create_table "comments", force: :cascade do |t|
    t.string "内容"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "song_id", null: false
    t.integer "com_manipulator_id", null: false
    t.index ["com_manipulator_id"], name: "index_comments_on_com_manipulator_id"
    t.index ["song_id"], name: "index_comments_on_song_id"
  end

  create_table "manipulators", force: :cascade do |t|
    t.string "名称"
    t.string "密码"
    t.string "类型"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notices", force: :cascade do |t|
    t.string "类型"
    t.string "wh状态"
    t.string "ma状态"
    t.string "内容"
    t.string "原因"
    t.integer "whistleblower_id", null: false
    t.integer "manipulator_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manipulator_id"], name: "index_notices_on_manipulator_id"
    t.index ["whistleblower_id"], name: "index_notices_on_whistleblower_id"
  end

  create_table "pictures", force: :cascade do |t|
    t.string "图片"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "song_id"
    t.integer "manipulator_id"
    t.index ["manipulator_id"], name: "index_pictures_on_manipulator_id"
    t.index ["song_id"], name: "index_pictures_on_song_id"
  end

  create_table "reports", force: :cascade do |t|
    t.string "内容"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "状态"
    t.integer "comment_id", null: false
    t.integer "manipulator_id", null: false
    t.index ["comment_id"], name: "index_reports_on_comment_id"
    t.index ["manipulator_id"], name: "index_reports_on_manipulator_id"
  end

  create_table "song_types", force: :cascade do |t|
    t.string "名称"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "songs", force: :cascade do |t|
    t.string "演唱"
    t.string "作词"
    t.string "作曲"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "名称"
    t.integer "manipulator_id", null: false
    t.integer "song_type_id"
    t.index ["manipulator_id"], name: "index_songs_on_manipulator_id"
    t.index ["song_type_id"], name: "index_songs_on_song_type_id"
  end

  add_foreign_key "comments", "manipulators", column: "com_manipulator_id"
  add_foreign_key "comments", "songs"
  add_foreign_key "notices", "manipulators"
  add_foreign_key "notices", "manipulators", column: "whistleblower_id"
  add_foreign_key "pictures", "manipulators"
  add_foreign_key "pictures", "songs"
  add_foreign_key "reports", "comments"
  add_foreign_key "reports", "manipulators"
  add_foreign_key "songs", "manipulators"
  add_foreign_key "songs", "song_types"
end
