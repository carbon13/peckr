# encoding: utf-8
class TickerSymbol < ActiveRecord::Base
  has_many :quotes, primary_key: :ticker_symbol, foreign_key: :ticker_symbol_id
  scope :selected, -> { where{ selected == 1 } }
  scope :ordered, -> { order(sort_id: :asc, created_at: :asc) }
  scope :not_updated, -> { where{ updated_at != Date.today } }
end