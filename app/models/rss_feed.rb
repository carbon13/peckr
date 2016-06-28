# encoding: utf-8
class RssFeed < ActiveRecord::Base
  belongs_to :rss_source, foreign_key: 'link'
  has_one :rss_detail

  scope :no_detail, -> { where{ id.not_in(RssDetail.select{ rss_feed_id }) } }
end
