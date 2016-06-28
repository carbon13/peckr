# encoding: utf-8
class Event < ActiveRecord::Base
  scope :selected, -> { where{ selected == 1 } }

  def registered?
    !self.find_by(datetime: self.datetime, country_id: self.country_id, indicator: self.indicator).nil?
  end
end
