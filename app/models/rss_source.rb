# encoding: utf-8
class RssSource < ActiveRecord::Base
  has_many :rss_feeds
  has_many :rss_bodies, through: :rss_feeds

  scope :has_no_details, -> { where{title = nil | description = nil} }

  def has_no_details? 
    !(self.title && self.description)
  end

  def dead?
    !(self.rss_feeds.where{created_at >= 2.weeks.ago}.exists?)
  end

  def registered?
    !!RssSource.find_by(link: self.link).exists?
  end
end