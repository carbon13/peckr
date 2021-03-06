# encoding: utf-8
require 'yaml'
require 'net/http'
require 'uri'
require 'open-uri'
require 'bundler'
require 'logger'
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

  @@log = Logger.new('log/error.log')
  @@log.level=Logger::ERROR
  def perform
    Thread.new do 
      TweetsCollector.new.sample_tweets
    end
    every(30.seconds, 'xchanges_and_quotes_collection', thread: true) do
      XchangesCollector.new.query_and_store
      QuotesCollector.new.query_and_store
    end
    every(10.minutes, 'rss_collection', thread: true) do
      RssCollector.new.query_and_store
    end
    every(1.day, 'recalculation_and_events_collection', at: '05:00', thread: true) do
      XchangesCollector.new.recalculate_change
      # EventsCollector.new.query_and_store
    end
  end
end

Peckr.new.perform
