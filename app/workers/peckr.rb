# encoding: utf-8
require 'pry'
require 'yaml'
require 'net/http'
require 'uri'
require 'open-uri'
require 'bundler'
Bundler.require

$ENV = ENV['ENV'] || 'development'
$APP_ROOT_PATH = File.expand_path('../../../', __FILE__)
$DB_CONFIG = YAML.load(ERB.new(File.read("#{$APP_ROOT_PATH}/config/database.yml")).result)

Dir["#{$APP_ROOT_PATH}/app/models/*.rb"].each do |file|
  require file
end

Dir["#{$APP_ROOT_PATH}/app/collectors/*.rb"].each do |file|
  require file
end

ActiveRecord::Base.establish_connection($DB_CONFIG[$ENV])
ActiveRecord::Base.logger = Logger.new("#{$APP_ROOT_PATH}/log/database_#{$ENV}.log")
ActiveRecord::Base.default_timezone = :utc
Time.zone_default = Time.find_zone! 'UTC'

class Peckr
  include Clockwork

  def perform
    every(10.seconds, 'xchanges_and_quotes_collection', thread: true) do
      XchangesCollector.new.query_and_store
      QuotesCollector.new.query_and_store
    end

    every(10.minutes, 'rss_feeds_collection', thread: true) do
      RSSFeedsCollector.new.query_and_store
    end

    every(1.day, 'recalculation', at: '05:00', thread: true) do
      XchangesCollector.new.recalculate_change
    end

    every(1.day, 'tweet_collection', at: '00:00', thread: true) do 
      TweetsCollector.new.sample_tweets
    end
  end
end

Peckr.new.perform