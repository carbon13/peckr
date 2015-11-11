# encoding: utf-8
class CreateAnglrModels < ActiveRecord::Migration
  def self.up
    create_table :floater_types do |t|
      t.string :name
      t.text :description
      t.integer :sort_id, default: 2**31-1

      t.timestamps null: true, default: Time.at(0)
    end

    create_table :floaters do |t|
      t.references :floater_type
      t.string :pair_id
      t.float :value
      t.datetime :start_at
      t.datetime :end_at
      t.integer :durability
      t.boolean :active, default: true, null: false

      t.timestamps null: false
    end
  end

  def self.down
    drop_table :floaters
    drop_table :floater_types
  end
end