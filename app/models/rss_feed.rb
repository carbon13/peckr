# encoding: utf-8
class RSSFeed < ActiveRecord::Base
  belongs_to :rss_source, foreign_key: 'link'
  has_one :rss_body

  scope :no_body, -> { where{ id.not_in(RssBody.select{ rss_feed_id }) } }
end
