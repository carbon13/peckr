# encoding: utf-8
class Xchange < ActiveRecord::Base
  belongs_to :pair
  has_one :current_previous, foreign_key: :outer_id
  has_one :xchange, through: :current_previous
  
  scope :ordered_desc, -> { order(datetime: :desc, created_at: :desc, id: :desc) }
  scope :ordered_asc, -> { order(datetime: :asc, created_at: :asc, id: :asc) }
  scope :joined_previous, -> { joins{ current_previous.xchange.inner }.select{ ['xchanges.*', 'xchanges.rate - xchanges_current_previous.rate'] } }
  scope :pair_id_in, -> (pair_ids) { where{ pair_id >> pair_ids} }

  def self.current(target_pair_id)
    self.where{ pair_id == target_pair_id }.ordered_desc.first
  end

  def self.current_datetime
    self.ordered_desc.first.datetime
  end

  def previous(self_pair_id = pair_id, self_datetime = self.datetime, self_created_at = self.created_at) 
    self_created_at ||= Time.now
    self.class.where{ pair_id == self_pair_id }.where{ datetime <= self_datetime }.where{ created_at < self_created_at }.ordered_desc.first
  end

  def previous_rate
    rate - change
  end

  def next(self_pair_id = pair_id, self_datetime = self.datetime, self_created_at = self.created_at)
    self.class.where{ pair_id == self_pair_id }.where{ datetime >= self_datetime }.where{ created_at > self_created_at }.ordered_asc.first
  end

  def registered?(self_pair_id = pair_id, self_rate = self.rate, self_datetime = self.datetime)
    !self.class.try(:find_by, pair_id: self_pair_id, rate: self_rate, datetime: self_datetime).nil?
  end
end
