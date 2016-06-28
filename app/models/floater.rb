# encoding: utf-8
class Floater < ActiveRecord::Base
  belongs_to :floater_type
  belongs_to :pair
  
  scope :active, -> { where{ active == 1 }.where{ durability > 0 }.where{ (start_at <= Time.now) & (end_at >= Time.now) } }
  scope :inactive, -> { where{ active == 0 } }
  scope :thresholds, -> { where{ floater_type_id == 1 } }
  scope :velocity, -> { where{ floater_type_id == 2 } }
  scope :timers, -> { where{ floater_type_id == 3 } }
  scope :state, -> { where{ floater_type_id == 4 } }

  def struck?(*)
    raise
  end
end
