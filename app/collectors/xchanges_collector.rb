# encoding: utf-8
require "#{$APP_ROOT_PATH}/app/collectors/yahoo_collector.rb"

class XchangesCollector < YahooCollector
  def initialize(table_name = 'yahoo.finance.xchange')
    super(table_name)
  end

  def query_and_store
    store(query)
  end

  def query
    column_search  = 's' # symbol
    selected_pairs = Pair.selected.pluck(:pair_id)
    column_select  = 'snl1d1t1ab'
    where_in(column_search, selected_pairs, column_select)
  end

  def store(results)
    ActiveRecord::Base.transaction do
      results.each do |result|
        current_xchange = Xchange.new
        # NOTE: Change column name because 'id' is reserved by ActiveRecord.
        current_xchange.pair_id  = convert_nil(result[0])
        current_xchange.name     = convert_nil(result[1])
        current_xchange.rate     = convert_nil(result[2])
        current_xchange.datetime = datetime(result)
        current_xchange.ask      = convert_nil(result[5])
        current_xchange.bid      = convert_nil(result[6])
        current_xchange.change   = change(current_xchange)
        
        current_xchange.save unless current_xchange.registered?
      end
    end
  end

  def datetime(result)
    begin
      Time.strptime("#{result[3]} #{result[4]} +0000", '%m/%d/%Y %H:%M%p %z').utc
    rescue
      nil
    end
  end

  def change(xchange)
    xchange.previous.nil? ? 0.0 : xchange.rate - xchange.previous.rate
  end

  def recalculate_change
    pair_ids = Xchange.uniq.pluck(:pair_id)
    pairs_with_xchanges = Pair.pair_id_in(pair_ids).with_xchanges
    pairs_with_xchanges.each do |pair|
      create_ordered_keys(pair)
      update_change
    end
  end

  def create_ordered_keys(pair)
    xchange_orderedkeys = []
    ActiveRecord::Base.transaction do
      OrderedKey.delete_all
      xchange_ids_ordered = pair.xchanges.ordered_desc.pluck(:id)
      xchange_ids_ordered.each { |xchange_id| xchange_orderedkeys << OrderedKey.new(outer_id: xchange_id) }
      OrderedKey.import([:outer_id], xchange_orderedkeys, validate: false)
    end
  end

  def update_change
    updated_xchanges = []
    xchanges_joined_previous = Xchange.joined_previous.all
    ActiveRecord::Base.transaction do
      xchanges_joined_previous.find_each do |xchange|
        xchange.change = xchange.attributes['xchanges.rate - xchanges_current_previous.rate'] || 0.0
        # OPTIMIZE: "on_duplicate_key_update" option for bulk update is only available on mysql.
        #   Use ActiveRecord "save" method instead.
        ['mysql'].include?($DB_CONFIG[$ENV]['adapter']) ? updated_xchanges << xchange : xchange.save
      end
      if ['mysql'].include?($DB_CONFIG[$ENV]['adapter'])
        maped_updated_xchanges = updated_xchanges.map { |xchange| [xchange.id, xchange.change] }
        Xchange.import([:id, :change], maped_updated_xchanges, on_duplicate_key_update: [:id])
      end
      OrderedKey.delete_all
    end
  end
end
