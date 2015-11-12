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
  include Clockwork
  
  floator_type_names = %w(threshold velocity)
  floator_type_names.each do |name|
    define_method "check_#{name}" do
      floaters = Object.const_get("#{name.camelize}").active.all
      floaters.each do |floater|
        current_xchange = Xchange.current(floater.pair_id)
        puts "#{floater.struck?(current_xchange)} TH: #{floater.value}/#{floater.pair_id}, TR: #{current_xchange.rate - current_xchange.change} -> #{current_xchange.rate}"
        if floater.struck?(current_xchange)
          message = "TH: #{floater.value}/#{floater.pair_id}, TR: #{current_xchange.rate - current_xchange.change} -> #{current_xchange.rate}"
          tweet(message)
          floater.durability -= 1
          floater.save
        end
      end
    end
  end

  def tweet(message)
    $TWITTER_API_CONFIG = YAML.load(ERB.new(File.read("#{$APP_ROOT_PATH}/config/twitter_api.yml")).result)
    twitter_client = Twitter::REST::Client.new($TWITTER_API_CONFIG[$ENV])
  end

  def perform
    every(10.seconds, 'check_floaters') do
      check_threshold
      check_velocity
    end
  end
end

anglr = Anglr.new.perform