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

ActiveRecord::Schema[7.2].define(version: 2024_09_22_090310) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_photobooths", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "print", default: false
    t.integer "paper", default: 0
    t.boolean "thermal", default: false
    t.string "overlay"
    t.string "ai_api"
    t.integer "selected_themes", default: [], array: true
    t.bigint "event_id", null: false
    t.index ["event_id"], name: "index_ai_photobooths_on_event_id"
  end

  create_table "ai_themes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "prompt"
    t.text "negative_prompt"
    t.text "styles", default: "[\"Steampunk 2\"]"
    t.string "preview"
  end

  create_table "events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.text "description"
    t.integer "booth_type", default: 0
  end

  create_table "exports", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "filename"
    t.string "compress"
    t.string "cloud"
    t.integer "filetype"
    t.boolean "printable", default: false
    t.bigint "session_id", null: false
    t.index ["session_id"], name: "index_exports_on_session_id"
  end

  create_table "photobooths", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "print", default: false
    t.integer "paper", default: 0
    t.boolean "thermal", default: false
    t.string "overlay"
    t.jsonb "overlay_layout"
    t.string "overlay_horizontal"
    t.boolean "use_overlay_horizontal", default: false
    t.bigint "event_id", null: false
    t.index ["event_id"], name: "index_photobooths_on_event_id"
  end

  create_table "raws", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "filename"
    t.string "compress"
    t.string "cloud"
    t.integer "filetype"
    t.boolean "selected"
    t.bigint "session_id", null: false
    t.index ["session_id"], name: "index_raws_on_session_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.text "error"
    t.bigint "event_id", null: false
    t.bigint "ai_theme_id"
    t.index ["ai_theme_id"], name: "index_sessions_on_ai_theme_id"
    t.index ["event_id"], name: "index_sessions_on_event_id"
  end

  add_foreign_key "ai_photobooths", "events"
  add_foreign_key "exports", "sessions"
  add_foreign_key "photobooths", "events"
  add_foreign_key "raws", "sessions"
  add_foreign_key "sessions", "ai_themes"
  add_foreign_key "sessions", "events"
end
