# encoding: utf-8
class XchangeStastic < ActiveRecord::Base
  belongs_to :period
  belongs_to :pair
  has_one :quote_stastic, through: :period
  has_one :rss_feed_stastic, through: :period
  has_one :tweet_stastic, through: :period
end
