# encoding: utf-8
class RssBody < ActiveRecord::Base
  belongs_to :rss_feed
end