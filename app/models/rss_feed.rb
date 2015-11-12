# encoding: utf-8
class RssFeed < ActiveRecord::Base
  belongs_to :rss_source, foreign_key: 'link'
  has_one :rss_body

  scope :has_no_body, -> { where{ id.not_in(RssBody.select{ rss_feed_id }) } }
end