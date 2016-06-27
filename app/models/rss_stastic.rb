# encoding: utf-8
class RssFeedStastic < ActiveRecord::Base
  belongs_to :period
  has_one :xchange_stastic, through: :period
  has_one :quote_stastic, through: :period
  has_one :tweet_stastic, through: :period
end
