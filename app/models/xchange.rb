# encoding: utf-8
class Xchange < ActiveRecord::Base
  belongs_to :pair
  has_one :current_previous, foreign_key: :outer_id
  has_one :xchange, through: :current_previous

  scope :ordered_desc, -> { order(date: :desc, time: :desc, created_at: :desc, id: :desc) }
  scope :ordered_asc, -> { order(date: :asc, time: :asc, created_at: :asc, id: :asc) }
  scope :joined_previous, -> { joins{ current_previous.xchange.inner }.select{['xchanges.*', 'xchanges.rate - xchanges_current_previous.rate']} }
  scope :pair_in, ->(pair_ids){ where{ pair_id << pair_ids} }

  def self.current(target_pair_id)
    Xchange.where{ pair_id == target_pair_id }.ordered_desc.first
  end
  
  def previous(self_pair_id = self.pair_id, self_date = self.date, self_time = self.time, self_created_at = self.created_at)
    Xchange.where{ pair_id == self_pair_id }.where{ (date < self_date) | ((date == self_date) & (time <= self_time) & (created_at < self_created_at)) }.ordered_desc.first
  end

  def next(self_pair_id = self.pair_id, self_date = self.date, self_time = self.time, self_created_at = self.created_at)
    Xchange.where{ pair_id == self_pair_id }.where{ (date > self_date) | ((date == self_date) & (time >= self_time) & (created_at > self_created_at)) }.ordered_asc.first
  end

  def registered?(self_pair_id = self.pair_id, self_rate = self.rate, self_date = self.date, self_time = self.time)
    Xchange.where{ pair_id == self_pair_id }.exists? ? !!Xchange.find_by(pair_id: self_pair_id, rate: self_rate, date: self_date, time: self_time) : false
  end
end