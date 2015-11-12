# encoding: utf-8
require "#{$APP_ROOT_PATH}/app/collectors/yql_collector.rb"

class QuotesCollector < YQLCollector
  def initialize(table_name = 'yahoo.finance.quote')
    super(table_name)
  end

  def query_and_store
    store(query)
  end

  def query
    selected_ticker_symbols = TickerSymbol.selected.pluck(:ticker_symbol_id)
    where_in(:symbol, selected_ticker_symbols)
  end

  def store(results)
    ActiveRecord::Base.transaction do
      results.each do |result|
        current_quote = Quote.new
        current_quote.average_daily_volume  = result['AverageDailyVolume']
        current_quote.change                = result['Change']
        current_quote.days_low              = result['DaysLow']
        current_quote.days_high             = result['DaysHigh']
        current_quote.year_low              = result['YearLow']
        current_quote.year_high             = result['YearHigh']
        current_quote.market_capitalization = result['MarketCapitalization']
        current_quote.last_trade_price_only = result['LastTradePriceOnly']
        current_quote.days_range            = result['DaysRange']
        current_quote.name                  = result['Name']
        # NOTE: Change column name according to ActiveRecord foreginkey naming rule.
        current_quote.ticker_symbol_id      = result['Symbol']
        current_quote.volume                = result['Volume']
        current_quote.stock_exchange        = result['StockExchange']
        current_quote.save unless current_quote.registered?
      end
    end
  end

  def update_master
    ActiveRecord::Base.transaction do
      ticker_symbol_ids = TickerSymbol.all.pluck(:ticker_symbol_id)
      results = where_in(:symbol, ticker_symbol_ids)
      results.each do |result|
        ticker_symbol = TickerSymbol.find_by(ticker_symbol_id: result['Symbol'])
        next unless ticker_symbol
        ticker_symbol.name = result['Name'] || 'Unknown'
        # ticker_symbol.disabled = false
        ticker_symbol.save
      end
      not_updated_ticker_symbols = TickerSymbol.not_updated
      # not_updated_ticker_symbols.update_all(disabled: true)
    end
  end
end
