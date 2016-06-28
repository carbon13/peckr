# encoding: utf-8
require 'bundler'
Bundler.require
require 'csv'

$ENV = ENV['ENV'] || 'development'
$APP_ROOT_PATH = File.expand_path('../../../', __FILE__)
$DB_CONFIG = YAML.load(ERB.new(File.read("#{$APP_ROOT_PATH}/config/database.yml")).result)
ActiveRecord::Base.establish_connection($DB_CONFIG[$ENV])
ActiveRecord::Base.logger = Logger.new("#{$APP_ROOT_PATH}/log/database_#{$ENV}.log")

Dir["#{$APP_ROOT_PATH}/app/models/*.rb"].each do |file|
  require file
end

# class Scholr
#   include Clockwork
#
#   def create_periods
#     current_datetime = Xchange.current_datetime
#     period_units = PeriodUnit.where{ unit > 10 }
#     period_units.each do |unit|
#       init_start_at = unit.periods.ordered_asc.last.try(:end_at) || Time.utc(2015, 11, 9, 0, 0, 0)
#       ActiveRecord::Base.transaction do
#         start_at = init_start_at
#         periods = []
#         while start_at < current_datetime && start_at + unit.unit < current_datetime do
#           periods << Period.new(period_unit_id: unit.id, start_at: start_at, end_at: start_at + unit.unit)
#           start_at += unit.unit
#         end
#         Period.import([:period_unit_id, :start_at, :end_at], periods, validate: false)
#       end
#     end
#   end

#   def create_xchange_stastics
#     r = RSRuby.instance
#     Period.no_xchange_stastics.each do |period|
#       xchange_stastics = []
#       Pair.all.pluck(:pair_id).each do |pair_id|
#         aggregated_xchanges = period.xchanges.pair_id_in(pair_id)
#         next if aggregated_xchanges.empty?
#         rate_array = aggregated_xchanges.pluck(:rate)
#         change_array = aggregated_xchanges.pluck(:change)
#         xchange_stastic = XchangeStastic.new
#         xchange_stastic.period_id     = period.id
#         xchange_stastic.pair_id       = pair_id
#         xchange_stastic.rate_mean     = r.mean(rate_array)
#         xchange_stastic.rate_median   = r.median(rate_array)
#         xchange_stastic.rate_min      = r.min(rate_array)
#         xchange_stastic.rate_max      = r.max(rate_array)
#         xchange_stastic.rate_sd       = r.sd(rate_array) unless r.sd(rate_array).nan?
#         xchange_stastic.rate_sum      = r.sum(rate_array)
#         xchange_stastic.change_mean   = r.mean(change_array)
#         xchange_stastic.change_median = r.median(change_array)
#         xchange_stastic.change_min    = r.min(change_array)
#         xchange_stastic.change_max    = r.max(change_array)
#         xchange_stastic.change_sd     = r.sd(change_array) unless r.sd(change_array).nan?
#         xchange_stastic.change_sum    = r.sum(change_array)
#         xchange_stastics << xchange_stastic
#       end
#       XchangeStastic.import([:id, :period_id, :pair_id, :rate_mean, :rate_median, :rate_min, :rate_max, :rate_sd, :rate_sum, :change_mean, :change_median, :change_min, :change_max, :change_sd, :change_sum], xchange_stastics, validate: false)
#     end
#   end

#   def create_rss_morphemes
# nm = Natto::MeCab.new
# rss_morphems = []
# RssDetail.no_morpheme.each do |detail|
#   word_hash = {}
#   nm.parse(detail.detail) do |n|
#     word_hash[n.surface] ? word_hash[n.surface] += 1 : word_hash[n.surface] = 1 if !n.is_eos? && (noun?(n) || verb?(n))
#   end
#   word_hash.each do |k, v|
#     rss_morpheme = RssMorpheme.new
#     rss_morpheme.surface     = k
#     rss_morpheme.count       = v
#     rss_morpheme.rss_body_id = detail.id
#     rss_morphems << rss_morpheme
#   end
# end
# RssMorpheme.import rss_body_morphems
#   end


def datetime(datetime_str)
  begin
    Time.strptime(datetime_str, '%Y-%m-%d %H:%M:%s %z').utc
  rescue
    nil
  end
end

# Scholr.new.create_rss_feed_morpheme
# Scholr.new.perform
