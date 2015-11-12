# encoding: utf-8
class RSSBody < ActiveRecord::Base
  belongs_to :rss_feed
end
