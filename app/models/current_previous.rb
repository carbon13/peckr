# encoding: utf-8
class CurrentPrevious < ActiveRecord::Base
  belongs_to :xchange, primary_key: :outer_id
  has_one :xchange, primary_key: :inner_id, foreign_key: :id
  self.table_name = 'current_previous'
end
