# encoding: utf-8
class RSSSource < ActiveRecord::Base
  has_many :rss_feeds
  has_many :rss_bodies, through: :rss_feeds
  
  scope :no_details, -> { where{ (title == nil) | (description == nil) } }

  def has_no_details?
    !(title && description)
  end

  def dead?
    !(rss_feeds.where{ created_at >= 2.weeks.ago }.exists?)
  end

  def registered?
    !!RSSSource.find_by(link: link).exists?
  end
end
