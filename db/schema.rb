# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140514124206) do

  create_table "editions", force: true do |t|
    t.integer  "oclc_id"
    t.integer  "best_match_id"
    t.integer  "marc_record_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "finc_records", force: true do |t|
    t.text     "url"
    t.integer  "marc_record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fincs", force: true do |t|
    t.integer  "edition_id"
    t.integer  "finc_record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fincs", ["edition_id"], name: "index_fincs_on_edition_id"
  add_index "fincs", ["finc_record_id"], name: "index_fincs_on_finc_record_id", unique: true

  create_table "marc_records", force: true do |t|
    t.text     "marc"
    t.boolean  "isValidMarcXml"
    t.text     "keyArray"
    t.text     "fingerprintHash"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oclcs", force: true do |t|
    t.integer  "number"
    t.integer  "marc_record_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oclcs", ["marc_record_id"], name: "index_oclcs_on_marc_record_id", unique: true
  add_index "oclcs", ["number"], name: "index_oclcs_on_number", unique: true

  create_table "perseus_records", force: true do |t|
    t.integer  "edition_id"
    t.integer  "marc_record_id"
    t.text     "urn"
    t.text     "mods"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "xoclcs", force: true do |t|
    t.integer  "edition_id"
    t.integer  "oclc_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
