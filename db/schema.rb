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

ActiveRecord::Schema.define(version: 20130609090051) do

  create_table "evaluations", force: true do |t|
    t.integer  "market_id"
    t.integer  "buyable_id"
    t.string   "buyable_type"
    t.integer  "sellable_id"
    t.string   "sellable_type"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "evaluations", ["buyable_id", "buyable_type"], name: "index_evaluations_on_buyable_id_and_buyable_type", using: :btree
  add_index "evaluations", ["market_id"], name: "index_evaluations_on_market_id", using: :btree
  add_index "evaluations", ["sellable_id", "sellable_type"], name: "index_evaluations_on_sellable_id_and_sellable_type", using: :btree

  create_table "items", force: true do |t|
    t.integer  "sellable_id"
    t.string   "sellable_type"
    t.string   "name"
    t.float    "fixed_price"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["sellable_id", "sellable_type"], name: "index_items_on_sellable_id_and_sellable_type", using: :btree

  create_table "markets", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.integer  "people_count"
    t.integer  "trades_count"
    t.string   "system",                        default: "PICSY"
    t.integer  "evaluation_parameter"
    t.integer  "initial_self_evaluation"
    t.float    "natural_recovery_ratio"
    t.integer  "natural_recovery_interval_sec"
    t.datetime "last_natural_recovery_at"
    t.datetime "last_trade_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", force: true do |t|
    t.integer  "user_id"
    t.integer  "market_id"
    t.string   "name"
    t.string   "state"
    t.float    "contribution",   default: 0.0
    t.float    "purchase_power", default: 0.0
    t.float    "picsy_effect",   default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "people", ["market_id"], name: "index_people_on_market_id", using: :btree
  add_index "people", ["user_id"], name: "index_people_on_user_id", using: :btree

  create_table "propagations", force: true do |t|
    t.integer  "market_id"
    t.integer  "trade_id"
    t.integer  "evaluatable_id"
    t.string   "evaluatable_type"
    t.float    "amount"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "propagations", ["evaluatable_id", "evaluatable_type"], name: "index_propagations_on_evaluatable_id_and_evaluatable_type", using: :btree
  add_index "propagations", ["market_id"], name: "index_propagations_on_market_id", using: :btree
  add_index "propagations", ["trade_id"], name: "index_propagations_on_trade_id", using: :btree

  create_table "trades", force: true do |t|
    t.integer  "market_id"
    t.integer  "buyable_id"
    t.string   "buyable_type"
    t.integer  "sellable_id"
    t.string   "sellable_type"
    t.integer  "item_id"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trades", ["buyable_id", "buyable_type"], name: "index_trades_on_buyable_id_and_buyable_type", using: :btree
  add_index "trades", ["item_id"], name: "index_trades_on_item_id", using: :btree
  add_index "trades", ["market_id"], name: "index_trades_on_market_id", using: :btree
  add_index "trades", ["sellable_id", "sellable_type"], name: "index_trades_on_sellable_id_and_sellable_type", using: :btree

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
    t.string   "image"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
