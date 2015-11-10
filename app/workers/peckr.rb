# encoding: utf-8
require 'pry'
require 'yaml'
require 'net/http'
require 'uri'
require 'open-uri'
require 'bundler'
Bundler.require

$ENV             = ENV['ENV'] || 'development'
$APP_ROOT_PATH ||= File.expand_path('../../../', __FILE__)
$DB_CONFIG     ||= YAML.load_file("#{$APP_ROOT_PATH}/config/database.yml")

Dir["#{$APP_ROOT_PATH}/app/models/*.rb"].each do |file|
  require file
end

Dir["#{$APP_ROOT_PATH}/app/collectors/*.rb"].each do |file|
  require file
end

class Peckr
  ActiveRecord::Base.establish_connection($DB_CONFIG[$ENV])
  ActiveRecord::Base.logger = Logger.new("#{$APP_ROOT_PATH}/log/database_#{$ENV}.log")
  ActiveRecord::Base.default_timezone = :utc
  Time.zone_default = Time.find_zone! 'UTC'

  def perform
    XchangesCollector.new.query_and_store
    QuotesCollector.new.query_and_store
    RssFeedsCollector.new.query_and_store
  end
end

Peckr.new.perform