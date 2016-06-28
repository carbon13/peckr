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

ActiveRecord::Schema.define(version: 20160521000004) do

  create_table "current_previous", id: false, force: :cascade do |t|
    t.integer "outer_id", limit: 4, null: false
    t.integer "inner_id", limit: 4
  end

  create_table "events", force: :cascade do |t|
    t.datetime "datetime"
    t.string   "country_id",             limit: 255
    t.text     "indicator",              limit: 65535
    t.integer  "impact_factor",          limit: 4
    t.string   "previous_value",         limit: 255
    t.string   "estimated_value",        limit: 255
    t.string   "previous_impact_usdjpy", limit: 255
    t.boolean  "selected",                             default: false, null: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  create_table "floater_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.integer  "sort_id",     limit: 4,     default: 2147483647
    t.datetime "created_at",                default: '1970-01-01 00:00:00'
    t.datetime "updated_at",                default: '1970-01-01 00:00:00'
  end

  create_table "floaters", force: :cascade do |t|
    t.integer  "floater_type_id", limit: 4
    t.string   "pair_id",         limit: 255
    t.float    "value",           limit: 24
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer  "durability",      limit: 4
    t.boolean  "active",                      default: true, null: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "ordered_keys", force: :cascade do |t|
    t.integer "outer_id", limit: 4, null: false
  end

  create_table "pairs", force: :cascade do |t|
    t.string   "pair_id",    limit: 255,                                 null: false
    t.string   "name",       limit: 255
    t.string   "name_jp",    limit: 255
    t.boolean  "selected",               default: false,                 null: false
    t.integer  "sort_id",    limit: 4,   default: 2147483647
    t.datetime "created_at",             default: '1970-01-01 00:00:00'
    t.datetime "updated_at",             default: '1970-01-01 00:00:00'
  end

  create_table "period_units", force: :cascade do |t|
    t.integer  "unit",                  limit: 4
    t.string   "description",           limit: 255
    t.integer  "level",                 limit: 4
    t.integer  "parent_period_unit_id", limit: 4
    t.float    "ratio",                 limit: 24
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "period_units", ["parent_period_unit_id"], name: "index_period_units_on_parent_period_unit_id", using: :btree

  create_table "periods", force: :cascade do |t|
    t.integer  "period_unit_id", limit: 4
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "periods", ["period_unit_id"], name: "index_periods_on_period_unit_id", using: :btree

  create_table "quote_stastics", force: :cascade do |t|
    t.integer  "period_id",                    limit: 4
    t.integer  "ticker_symbol_id",             limit: 4
    t.float    "last_trade_price_only_mean",   limit: 24
    t.float    "last_trade_price_only_median", limit: 24
    t.float    "last_trade_price_only_min",    limit: 24
    t.float    "last_trade_price_only_max",    limit: 24
    t.float    "last_trade_price_only_sd",     limit: 24
    t.float    "last_trade_price_only_sum",    limit: 24
    t.float    "change_mean",                  limit: 24
    t.float    "change_median",                limit: 24
    t.float    "change_min",                   limit: 24
    t.float    "change_max",                   limit: 24
    t.float    "change_sd",                    limit: 24
    t.float    "change_sum",                   limit: 24
    t.boolean  "inflection_point",                        default: false, null: false
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
  end

  add_index "quote_stastics", ["change_mean"], name: "index_quote_stastics_on_change_mean", using: :btree
  add_index "quote_stastics", ["change_sd"], name: "index_quote_stastics_on_change_sd", using: :btree
  add_index "quote_stastics", ["change_sum"], name: "index_quote_stastics_on_change_sum", using: :btree
  add_index "quote_stastics", ["last_trade_price_only_mean"], name: "price_mean_index", using: :btree
  add_index "quote_stastics", ["last_trade_price_only_sd"], name: "price_sd_index", using: :btree
  add_index "quote_stastics", ["last_trade_price_only_sum"], name: "price_sum_index", using: :btree
  add_index "quote_stastics", ["period_id"], name: "index_quote_stastics_on_period_id", using: :btree
  add_index "quote_stastics", ["ticker_symbol_id"], name: "index_quote_stastics_on_ticker_symbol_id", unique: true, using: :btree

  create_table "quotes", force: :cascade do |t|
    t.string   "average_daily_volume",  limit: 255
    t.float    "change",                limit: 24
    t.float    "days_low",              limit: 24
    t.float    "days_high",             limit: 24
    t.float    "year_low",              limit: 24
    t.float    "year_high",             limit: 24
    t.float    "market_capitalization", limit: 24
    t.float    "last_trade_price_only", limit: 24
    t.string   "days_range",            limit: 255
    t.string   "name",                  limit: 255
    t.string   "ticker_symbol_id",      limit: 255
    t.integer  "volume",                limit: 4
    t.string   "stock_exchange",        limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "rss_details", force: :cascade do |t|
    t.integer  "rss_feed_id", limit: 4
    t.text     "body",        limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "rss_feeds", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "link",        limit: 255
    t.text     "description", limit: 65535
    t.string   "author",      limit: 255
    t.string   "category",    limit: 255
    t.text     "comments",    limit: 65535
    t.text     "enclosure",   limit: 65535
    t.string   "guid",        limit: 255
    t.datetime "pubdate"
    t.string   "source",      limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "rss_morphemes", force: :cascade do |t|
    t.string   "surface",       limit: 255
    t.string   "count",         limit: 255
    t.integer  "rss_detail_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "rss_sources", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.string   "atom_link",       limit: 255
    t.string   "link",            limit: 255,   null: false
    t.text     "description",     limit: 65535
    t.time     "last_build_date"
    t.string   "language",        limit: 255
    t.text     "generator",       limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  create_table "rss_stastics", force: :cascade do |t|
    t.integer  "period_id",                 limit: 4
    t.integer  "published_rss_feeds_count", limit: 4
    t.float    "score_mean",                limit: 24
    t.float    "score_median",              limit: 24
    t.float    "score_min",                 limit: 24
    t.float    "score_max",                 limit: 24
    t.float    "score_sd",                  limit: 24
    t.float    "score_sum",                 limit: 24
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "rss_stastics", ["period_id"], name: "index_rss_stastics_on_period_id", using: :btree
  add_index "rss_stastics", ["score_mean"], name: "index_rss_stastics_on_score_mean", using: :btree
  add_index "rss_stastics", ["score_sd"], name: "index_rss_stastics_on_score_sd", using: :btree
  add_index "rss_stastics", ["score_sum"], name: "index_rss_stastics_on_score_sum", using: :btree

  create_table "schedules", force: :cascade do |t|
    t.date     "date"
    t.time     "time"
    t.string   "currency",               limit: 255
    t.text     "indicator",              limit: 65535
    t.integer  "impact_factor",          limit: 4
    t.float    "previous_value",         limit: 24
    t.float    "estimated_value",        limit: 24
    t.string   "previous_impact_usdjpy", limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "schedules", ["date", "time"], name: "index_schedules_on_date_and_time", using: :btree

  create_table "ticker_symbols", force: :cascade do |t|
    t.string   "ticker_symbol_id", limit: 255
    t.string   "name",             limit: 255
    t.boolean  "selected",                     default: false,                 null: false
    t.boolean  "disabled",                     default: false,                 null: false
    t.integer  "sort_id",          limit: 4,   default: 2147483647
    t.datetime "created_at",                   default: '1970-01-01 00:00:00'
    t.datetime "updated_at",                   default: '1970-01-01 00:00:00'
  end

  create_table "tweet_details", force: :cascade do |t|
    t.string   "status_id",  limit: 255
    t.string   "user_id",    limit: 255
    t.datetime "tweeted_at"
    t.integer  "tweet_id",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "tweet_morphemes", force: :cascade do |t|
    t.string   "surface",    limit: 255
    t.string   "count",      limit: 255
    t.integer  "tweet_id",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "tweets", force: :cascade do |t|
    t.string   "status_id",  limit: 255
    t.string   "user_id",    limit: 255
    t.datetime "tweeted_at"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "xchange_stastics", force: :cascade do |t|
    t.integer  "period_id",        limit: 4
    t.string   "pair_id",          limit: 255
    t.float    "rate_mean",        limit: 24
    t.float    "rate_median",      limit: 24
    t.float    "rate_min",         limit: 24
    t.float    "rate_max",         limit: 24
    t.float    "rate_sd",          limit: 24
    t.float    "rate_sum",         limit: 24
    t.float    "change_mean",      limit: 24
    t.float    "change_median",    limit: 24
    t.float    "change_min",       limit: 24
    t.float    "change_max",       limit: 24
    t.float    "change_sd",        limit: 24
    t.float    "change_sum",       limit: 24
    t.boolean  "inflection_point",             default: false, null: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "xchange_stastics", ["change_mean"], name: "index_xchange_stastics_on_change_mean", using: :btree
  add_index "xchange_stastics", ["change_sd"], name: "index_xchange_stastics_on_change_sd", using: :btree
  add_index "xchange_stastics", ["change_sum"], name: "index_xchange_stastics_on_change_sum", using: :btree
  add_index "xchange_stastics", ["pair_id"], name: "index_xchange_stastics_on_pair_id", using: :btree
  add_index "xchange_stastics", ["period_id"], name: "index_xchange_stastics_on_period_id", using: :btree
  add_index "xchange_stastics", ["rate_mean"], name: "index_xchange_stastics_on_rate_mean", using: :btree
  add_index "xchange_stastics", ["rate_sd"], name: "index_xchange_stastics_on_rate_sd", using: :btree
  add_index "xchange_stastics", ["rate_sum"], name: "index_xchange_stastics_on_rate_sum", using: :btree

  create_table "xchanges", force: :cascade do |t|
    t.string   "pair_id",    limit: 255
    t.string   "name",       limit: 255
    t.float    "rate",       limit: 24
    t.datetime "datetime"
    t.float    "ask",        limit: 24
    t.float    "bid",        limit: 24
    t.float    "change",     limit: 24
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
