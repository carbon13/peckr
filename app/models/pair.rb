# encoding: utf-8
class Pair < ActiveRecord::Base
  has_many :xchanges, primary_key: :pair_id, foreign_key: :pair_id
  has_many :floaters, primary_key: :pair_id, foreign_key: :pair_id
  
  scope :selected, -> { where{ selected == 1 } }
  scope :pair_id_in, -> (pair_ids) { where{pair_id >> pair_ids } }
  scope :with_xchanges, -> { includes(:xchanges) }
end
