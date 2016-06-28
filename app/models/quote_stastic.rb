# encoding: utf-8
class QuoteStastic < ActiveRecord::Base
  belongs_to :period
  belongs_to :ticker_symbol
  has_one :xchange_stastic, through: :period  
  has_one :rss_feed_stastic, through: :period
  has_one :tweet_stastic, through: :period
end
