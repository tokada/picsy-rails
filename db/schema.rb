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

ActiveRecord::Schema.define(version: 20130602184210) do

  create_table "evaluations", force: true do |t|
    t.integer  "buyable_id"
    t.string   "buyable_type"
    t.integer  "sellable_id"
    t.string   "sellable_type"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "evaluations", ["buyable_id", "buyable_type"], name: "index_evaluations_on_buyable_id_and_buyable_type"
  add_index "evaluations", ["sellable_id", "sellable_type"], name: "index_evaluations_on_sellable_id_and_sellable_type"

  create_table "items", force: true do |t|
    t.integer  "sellable_id"
    t.string   "sellable_type"
    t.string   "name"
    t.float    "fixed_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["sellable_id", "sellable_type"], name: "index_items_on_sellable_id_and_sellable_type"

  create_table "people", force: true do |t|
    t.string   "name"
    t.string   "state"
    t.float    "contribution"
    t.float    "purchase_power"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "propagations", force: true do |t|
    t.integer  "trade_id"
    t.integer  "evaluatable_id"
    t.string   "evaluatable_type"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "propagations", ["evaluatable_id", "evaluatable_type"], name: "index_propagations_on_evaluatable_id_and_evaluatable_type"
  add_index "propagations", ["trade_id"], name: "index_propagations_on_trade_id"

  create_table "trades", force: true do |t|
    t.integer  "buyable_id"
    t.string   "buyable_type"
    t.integer  "sellable_id"
    t.string   "sellable_type"
    t.integer  "item_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trades", ["buyable_id", "buyable_type"], name: "index_trades_on_buyable_id_and_buyable_type"
  add_index "trades", ["item_id"], name: "index_trades_on_item_id"
  add_index "trades", ["sellable_id", "sellable_type"], name: "index_trades_on_sellable_id_and_sellable_type"

  create_table "users", force: true do |t|
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                 default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "uid",                 limit: 8
    t.string   "name"
    t.string   "provider"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
