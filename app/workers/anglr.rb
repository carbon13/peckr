# encoding: utf-8
require 'pry'
require 'yaml'
require 'erb'
require 'bundler'
Bundler.require

$ENV = ENV['ENV'] || 'development'
$APP_ROOT_PATH = File.expand_path('../../../', __FILE__)
$DB_CONFIG = YAML.load(ERB.new(File.read("#{$APP_ROOT_PATH}/config/database.yml")).result)

Dir["#{$APP_ROOT_PATH}/app/models/*.rb"].each do |file|
  require file
end

ActiveRecord::Base.establish_connection($DB_CONFIG[$ENV])
ActiveRecord::Base.logger = Logger.new("#{$APP_ROOT_PATH}/log/database_#{$ENV}.log")
ActiveRecord::Base.default_timezone = :utc
Time.zone_default = Time.find_zone! 'UTC'

class Anglr
  def check_threshold
    thresholds = Threshold.active.all
    thresholds.each do |threshold|
      current_xchange = Xchange.current(threshold.pair_id)
      if (threshold.value < current_xchange.rate && threshold.value > (current_xchange.rate - current_xchange.change)) ||
         (threshold.value > current_xchange.rate && threshold.value < (current_xchange.rate - current_xchange.change))
        message =  "TH: #{threshold.value}/#{threshold.pair_id}, TR: #{current_xchange.rate - current_xchange.change} -> #{current_xchange.rate}"
        tweet(message)
        threshold.durability -= 1
      end
    end
  end

  def tweet(message)
    twitter_api_config = YAML.load(ERB.new(File.read("#{$APP_ROOT_PATH}/config/twitter_api.yml")).result)
    twitter_client = Twitter::REST::Client.new(twitter_api_config[$ENV])
    twitter_client.update(message)
  end

  def check_state
  end

  def check_timer
  end

  def check_accelerator
  end

  def perform
    check_threshold
  end
end

anglr = Anglr.new.perform