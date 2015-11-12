# encoding: utf-8
class Tweet < ActiveRecord::Base
  has_many :tweet_morpheme_analyses
end
