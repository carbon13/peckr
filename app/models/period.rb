# encoding: utf-8
class Period < ActiveRecord::Base
  belongs_to :period_unit
  has_many :xchange_stastics
  has_one :quote_stastic
  has_one :rss_feed_stastic
  has_one :tweet_stastic

  scope :no_xchange_stastics, -> { where{ id.not_in(XchangeStastic.select{ period_id }) } }
  scope :ordered_asc, -> { order(end_at: :asc) }
  scope :ordered_desc, -> { order(start_at: :desc) }

  def self.last_end_at
    self.ordered_desc.try(:first).try(:end_at)
  end

  def xchanges(self_start_at = self.start_at, self_end_at = self.end_at)
    Xchange.where{ (datetime >= self_start_at) }.where{ (datetime < self_end_at) }.ordered_asc
  end

  def quotes(self_start_at = self.start_at, self_end_at = self.end_at)
    Xchange.where{ (created_at >= self.start_at) & (created_at) < self.end_at }.ordered_asc
  end
end
