# encoding: utf-8
class RssSource < ActiveRecord::Base
  has_many :rss_feeds
  has_many :rss_details, through: :rss_feeds
  has_many :rss_morphemes, through: :rss_details
  
  scope :no_details, -> { where{ (title == nil) | (description == nil) } }

  def has_no_details?
    !(title && description)
  end

  def dead?
    !(rss_feeds.where{ created_at >= 2.weeks.ago }.exists?)
  end

  def registered?
    !!RssSource.find_by(link: link).exists?
  end
end
