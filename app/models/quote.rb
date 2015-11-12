# encoding: utf-8
class Quote < ActiveRecord::Base
  belongs_to :ticker_symbol
  scope :ordered_desc, -> { order(created_at: :desc) }

  def self.current(ticker_symbol_id)
    Quote.where{ ticker_symbol_id == ticker_symbol_id }.ordered_desc.first
  end
  
  def previous(self_ticker_symbol_id = self.ticker_symbol_id, self_created_at = self.created_at)
    Quote.where{ ticker_symbol_id == self_ticker_symbol_id }.where{ created_at < self_created_at }.ordered_desc.first
  end

  def registered?(self_ticker_symbol_id = self.ticker_symbol_id, self_last_trade_price_only = self.last_trade_price_only)
    Quote.where{ ticker_symbol_id == self_ticker_symbol_id }.exists? ? Quote.where{ (ticker_symbol_id == self_ticker_symbol_id) & (last_trade_price_only == self_last_trade_price_only) & (created_at >= Date.today) & (created_at < Time.now + 5.minutes) }.exists? : false
  end
end