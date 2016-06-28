# encoding: utf-8
class PeriodUnit < ActiveRecord::Base
  belongs_to :parent, class_name: :PeriodUnit, foreign_key: :parent_period_unit_id
  has_many :children, class_name: :PeriodUnit, foreign_key: :parent_period_unit_id
  has_many :periods

  def self.in_10_sec
    self.find_by(id: 1)
  end

  def self.in_01_min
    self.find_by(id: 2)
  end

  def self.in_05_min
    self.find_by(id: 3)
  end

  def self.in_30_min
    self.find_by(id: 4)
  end

  def self.in_01_hr
    self.find_by(id: 5)
  end

  def self.in_04_hrs
    self.find_by(id: 6)
  end

  def self.in_01_day
    self.find_by(id: 7)
  end

  def self.in_05_days
    self.find_by(id: 8)
  end

  def self.in_01_week
    self.find_by(id: 9)
  end

  def self.in_25_days
    self.find_by(id: 10)
  end

  def self.in_01_month
    self.find_by(id: 11)
  end

  def self.in_75_days
    self.find_by(id: 12)
  end

  def self.in_13_weeks
    self.find_by(id: 13)
  end

  def self.in_26_weeks
    self.find_by(id: 14)
  end

  def self.in_52_weeks
    self.find_by(id: 15)
  end

  def self.in_24_months
    self.find_by(id: 16)
  end

  def self.in_60_months
    self.find_by(id: 17)
  end
end
