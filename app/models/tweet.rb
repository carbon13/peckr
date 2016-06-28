# encoding: utf-8
class Tweet < ActiveRecord::Base
  has_many :tweet_morphemes, foreign_key: 'status_id'
  accepts_nested_attributes_for :tweet_morphemes

end
