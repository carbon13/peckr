# encoding: utf-8
class CreateScholrModels < ActiveRecord::Migration
  def self.up
    unless ActiveRecord::Base.connection.table_exists? :period_units
      create_table :period_units do |t|
        t.integer :unit
        t.string :description
        t.integer :level
        t.references :parent_period_unit
        t.float :ratio

        t.timestamps null: false
      end
    end
    unless ActiveRecord::Base.connection.index_exists? :period_units, :index_period_units_on_parent_period_unit_id
      change_table :period_units do |t|
        t.index :parent_period_unit_id
      end
    end
    unless ActiveRecord::Base.connection.table_exists? :periods
      create_table :periods do |t|
        t.references :period_unit
        t.datetime :start_at
        t.datetime :end_at

        t.timestamps null: false
      end
    end
    unless ActiveRecord::Base.connection.index_exists? :periods, :index_periods_on_period_unit_id
      change_table :periods do |t|
        t.index :period_unit_id
      end
    end
    unless ActiveRecord::Base.connection.table_exists? :xchange_stastics
      create_table :xchange_stastics do |t|
        t.references :period
        t.string :pair_id
        t.float :rate_mean
        t.float :rate_median
        t.float :rate_min
        t.float :rate_max
        t.float :rate_sd
        t.float :rate_sum

        t.float :change_mean
        t.float :change_median
        t.float :change_min
        t.float :change_max
        t.float :change_sd
        t.float :change_sum

        t.boolean :inflection_point, default: false, null: false

        t.timestamps null: false
      end
    end
    unless ActiveRecord::Base.connection.index_exists? :xchange_stastics, :index_xchange_stastics_on_period_id
      change_table :xchange_stastics do |t|
        t.index [:period_id]
        t.index [:pair_id]
        t.index [:rate_mean]
        t.index [:rate_sd]
        t.index [:rate_sum]
        t.index [:change_mean]
        t.index [:change_sd]
        t.index [:change_sum]
      end
    end

   unless ActiveRecord::Base.connection.table_exists? :quote_stastics
      create_table :quote_stastics do |t|
        t.references :period
        t.references :ticker_symbol
        t.float :last_trade_price_only_mean
        t.float :last_trade_price_only_median
        t.float :last_trade_price_only_min
        t.float :last_trade_price_only_max
        t.float :last_trade_price_only_sd
        t.float :last_trade_price_only_sum

        t.float :change_mean
        t.float :change_median
        t.float :change_min
        t.float :change_max
        t.float :change_sd
        t.float :change_sum

        t.boolean :inflection_point, default: false, null: false

        t.timestamps null: false
      end
    end
    unless ActiveRecord::Base.connection.index_exists? :quote_stastics, :index_quote_stastics_on_period_id
      change_table :quote_stastics do |t|
        t.index [:period_id]
        t.index [:ticker_symbol_id], unique: :true
        t.index [:last_trade_price_only_mean], name: :price_mean_index
        t.index [:last_trade_price_only_sd], name: :price_sd_index
        t.index [:last_trade_price_only_sum], name: :price_sum_index
        t.index [:change_mean]
        t.index [:change_sd]
        t.index [:change_sum]
      end
    end
    unless ActiveRecord::Base.connection.table_exists? :rss_stastics
      create_table :rss_stastics do |t|
        t.references :period
        t.integer :published_rss_feeds_count
        t.float :score_mean
        t.float :score_median
        t.float :score_min
        t.float :score_max
        t.float :score_sd
        t.float :score_sum

        t.timestamps null: false
      end
    end
    unless ActiveRecord::Base.connection.index_exists? :rss_stastics, :index_rss_stastics_on_period_id
      change_table :rss_stastics do |t|
        t.index [:period_id]
        t.index [:score_mean]
        t.index [:score_sd]
        t.index [:score_sum]
      end
    end
    unless ActiveRecord::Base.connection.table_exists? :schedules
      create_table :schedules do |t|
        t.date :date
        t.time :time
        t.string :currency
        t.text :indicator
        t.integer :impact_factor
        t.float :previous_value
        t.float :estimated_value
        t.string :previous_impact_usdjpy

        t.timestamps null: false
      end
    end
    unless ActiveRecord::Base.connection.index_exists? :schedules, :index_schedules_on_date_time
      change_table :schedules do |t|
        t.index [:date, :time]
      end
    end
    unless ActiveRecord::Base.connection.table_exists? :rss_morphemes
      create_table :rss_morphemes do |t|
        t.string :surface
        t.string :count
        t.references :rss_detail

        t.timestamps null: false
      end
    end
  end

  def self.down
    drop_table :period_units
    drop_table :periods
    drop_table :xchange_stastics
    drop_table :quote_stastics
    drop_table :rss_stastics
    drop_table :schedules
    drop_table :rss_body_morpheme
  end
end