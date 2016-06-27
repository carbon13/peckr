# encoding: utf-8
require 'csv'

class YahooCollector
  def initialize(table_name, where_clause = nil)
    @table_name = table_name
    @where_clause = where_clause
  end

  def table_name=(table_name)
    @table_name = (table_name.is_a? String) ? table_name : table_name.to_s
  end

  def where_clause=(where_clause)
    @where_clause = where_clause
  end

  def where_in(column_search, values, column_select, records_per_request = 200)
    results_array = []
    values.each_slice(records_per_request).to_a.each do |sliced_values|
      where_clause = "#{column_search}=#{sliced_values.join(",")}"
      results_array << CSV.parse(where(where_clause, column_select))
    end
    results_array.flatten 1
  end

  def where(where_clause = nil, column_select = nil)
    @where_clause = where_clause || @where_clause
    query         = "http://download.finance.yahoo.com/d/quotes.csv?#{@where_clause}&f=#{column_select}"
    query_parsed  = Addressable::URI.parse(query)
    results       = Net::HTTP.get(query_parsed)
  end

  def exists?
    !!where
  end

  def query
    raise
  end

  def store
    raise
  end

  def convert_nil(data)
    'N/A' == data ? nil : data
  end
end

##
## CSV API options
##
## Pricing Dividends
# a: Ask  y: Dividend Yield
# b: Bid  d: Dividend per Share
# b2: Ask (Realtime)  r1: Dividend Pay Date
# b3: Bid (Realtime)  q: Ex-Dividend Date
# p: Previous Close
# o: Open
## Date
# c1: Change  d1: Last Trade Date
# c: Change & Percent Change  d2: Trade Date
# c6: Change (Realtime) t1: Last Trade Time
# k2: Change Percent (Realtime)
# p2: Change in Percent
## Averages
# c8: After Hours Change (Realtime) m5: Change From 200 Day Moving Average
# c3: Commission  m6: Percent Change From 200 Day Moving Average
# g: Day’s Low  m7: Change From 50 Day Moving Average
# h: Day’s High m8: Percent Change From 50 Day Moving Average
# k1: Last Trade (Realtime) With Time m3: 50 Day Moving Average
# l: Last Trade (With Time) m4: 200 Day Moving Average
# l1: Last Trade (Price Only)
# t8: 1 yr Target Price
## Misc
# w1: Day’s Value Change  g1: Holdings Gain Percent
# w4: Day’s Value Change (Realtime) g3: Annualized Gain
# p1: Price Paid  g4: Holdings Gain
# m: Day’s Range  g5: Holdings Gain Percent (Realtime)
# m2: Day’s Range (Realtime)  g6: Holdings Gain (Realtime)
# 52 Week Pricing Symbol Info
# k: 52 Week High v: More Info
# j: 52 week Low  j1: Market Capitalization
# j5: Change From 52 Week Low j3: Market Cap (Realtime)
# k4: Change From 52 week High  f6: Float Shares
# j6: Percent Change From 52 week Low n: Name
# k5: Percent Change From 52 week High  n4: Notes
# w: 52 week Range  s: Symbol
# s1: Shares Owned
# x: Stock Exchange
# j2: Shares Outstanding
## Volume
# v: Volume
# a5: Ask Size
# b6: Bid Size  Misc
# k3: Last Trade Size t7: Ticker Trend
# a2: Average Daily Volume  t6: Trade Links
# i5: Order Book (Realtime)
# Ratios  l2: High Limit
# e: Earnings per Share l3: Low Limit
# e7: EPS Estimate Current Year v1: Holdings Value
# e8: EPS Estimate Next Year  v7: Holdings Value (Realtime)
# e9: EPS Estimate Next Quarter s6 Revenue
# b4: Book Value
# j4: EBITDA
# p5: Price / Sales
# p6: Price / Book
# r: P/E Ratio
# r2: P/E Ratio (Realtime)
# r5: PEG Ratio
# r6: Price / EPS Estimate Current Year
# r7: Price / EPS Estimate Next Year
# s7: Short Ratio
