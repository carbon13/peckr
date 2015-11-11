# encoding: utf-8
class CreatePeckrModels < ActiveRecord::Migration
  def self.up
    create_table :xchanges do |t|
      t.string :pair_id
      t.string :name
      t.float :rate
      t.date :date
      t.time :time
      t.float :ask
      t.float :bid
      t.float :change

      t.timestamps null: false
    end

    create_table :pairs do |t|
      t.string :pair_id, null: false
      t.string :name
      t.string :name_jp
      t.boolean :selected, default: false, null: false
      t.integer :sort_id, default: 2**31-1

      t.timestamps null: true, default: Time.at(0)
    end

    create_table :rss_sources do |t|
      t.string :title
      t.string :atom_link
      t.string :link, null: false
      t.text :description
      t.time :last_build_date
      t.string :language
      t.text :generator

      t.timestamps null: false
    end

    create_table :rss_feeds do |t|
      t.string :title
      t.string :link
      t.text :description
      t.string :author
      t.string :category
      t.text :comments
      t.text :enclosure
      t.string :guid
      t.datetime :pubdate
      t.string :source

      t.timestamps null: false
    end

    create_table :rss_bodies do |t|
      t.references :rss_feed
      t.text :body

      t.timestamps null: false
    end

    create_table :ticker_symbols do |t|
      t.string :ticker_symbol_id, null: :false
      t.string :name
      t.boolean :selected, default: false, null: false
      t.boolean :disabled, default: false, null: false
      t.integer :sort_id, default: 2**31-1

      t.timestamps null: true, default: Time.at(0)
    end

    create_table :quotes do |t|
      t.string :average_daily_volume
      t.float :change
      t.float :days_low
      t.float :days_high
      t.float :year_low
      t.float :year_high
      t.float :market_capitalization
      t.float :last_trade_price_only
      t.string :days_range
      t.string :name
      t.references :ticker_symbol, null: :false
      t.integer :volume
      t.string :stock_exchange

      t.timestamps null: false
    end

    create_table :ordered_keys do |t|
      t.integer :outer_id, null: false
    end

    execute <<-SQL
      CREATE VIEW current_previous AS 
        SELECT outer_table.outer_id, inner_table.outer_id AS inner_id 
          FROM ordered_keys outer_table LEFT JOIN ordered_keys inner_table
            ON outer_table.id + 1 = inner_table.id
    SQL

  end

  def self.change
    add_index :xchanges, [:created_at, :time, :date]
    add_index :floater_types, [:sort_id]
    add_index :pairs, [:pair_id], unique: :true
    add_index :pairs, [:sort_id]
    add_index :rss_sources, [:link]
    add_index :ticker_symbols, [:ticker_symbol_id]
    add_index :ticker_symbols, [:sort_id]
    add_index :quotes, [:ticker_symbol]
  end

  def self.down
    execute <<-SQL
      DROP VIEW current_previous;
    SQL
    drop_table :ordered_key
    drop_table :xchanges
    drop_table :pairs
    drop_table :quotes
    drop_table :rss_sources
    drop_table :rss_feeds
    drop_table :rss_bodies
  end
end