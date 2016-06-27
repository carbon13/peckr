# encoding: utf-8
class RssDetail < ActiveRecord::Base
  belongs_to :rss_feed
  has_many :rss_morphemes

  scope :no_morphemes, -> { where{ id.not_in(RssMorpehme.select{ rss_detail_id }) } }
end
