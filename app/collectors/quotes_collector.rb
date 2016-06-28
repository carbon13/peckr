# encoding: utf-8
require "#{$APP_ROOT_PATH}/app/collectors/yahoo_collector.rb"

class QuotesCollector < YahooCollector
  def initialize(table_name = 'yahoo.finance.quote')
    super(table_name)
  end

  def query_and_store
    store(query)
  end

  def query
    column_search           = 's' # symbol
    ticker_symbols_selected = TickerSymbol.selected.pluck(:ticker_symbol_id)
    column_select           = 'a2c1ghjkj1l1mnsvx'
    where_in(column_search, ticker_symbols_selected, column_select)
  end

  def store(results)
    ActiveRecord::Base.transaction do
      results.each do |result|
        current_quote = Quote.new
        current_quote.average_daily_volume  = convert_nil(result[0])
        current_quote.change                = convert_nil(result[1])
        current_quote.days_low              = convert_nil(result[2])
        current_quote.days_high             = convert_nil(result[3])
        current_quote.year_low              = convert_nil(result[4])
        current_quote.year_high             = convert_nil(result[5])
        current_quote.market_capitalization = convert_nil(result[6])
        current_quote.last_trade_price_only = convert_nil(result[7])
        current_quote.days_range            = convert_nil(result[8])
        current_quote.name                  = convert_nil(result[9])
        # NOTE: Change column name according to ActiveRecord foreginkey naming rule.
        current_quote.ticker_symbol_id      = convert_nil(result[10])
        current_quote.volume                = convert_nil(result[11])
        current_quote.stock_exchange        = convert_nil(result[12])

        current_quote.save unless current_quote.registered?
      end
    end
  end

  def update_master
    column_search           =  's' # symbol
    ticker_symbols_stored = TickerSymbol.all.pluck(:ticker_symbol_id)
    column_select           = 'sn'
    results = where_in(column_search, ticker_symbols_stored, column_select)
    ActiveRecord::Base.transaction do
      results.each do |result|
        ticker_symbol = TickerSymbol.find_by(ticker_symbol_id: result[0])
        next unless ticker_symbol
        ticker_symbol.name = convert_nil(result[1]) || 'Unknown'
        ticker_symbol.disabled = 0
        ticker_symbol.save
      end
      not_updated_ticker_symbols = TickerSymbol.not_updated
      not_updated_ticker_symbols.update_all(disabled: 1)
    end
  end
end
