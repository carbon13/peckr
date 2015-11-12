# encoding: utf-8
require "#{$APP_ROOT_PATH}/app/collectors/yql_collector.rb"

class XchangesCollector < YQLCollector
  def initialize(table_name = 'yahoo.finance.xchange')
    super(table_name)
  end

  def query_and_store
    store(query)
  end

  def query
    selected_pairs = Pair.selected.pluck(:pair_id)
    where_in(:pair, selected_pairs)
  end

  def store(results)
    ActiveRecord::Base.transaction do
      results.each do |result|
        current_xchange = Xchange.new
        # NOTE: Change column name because 'id' is reserved by ActiveRecord.
        current_xchange.pair_id = result['id']
        current_xchange.name    = result['Name']
        current_xchange.rate    = result['Rate']
        current_xchange.date    = Date.strptime(result['Date'], '%m/%d/%Y')
        # HACK: To convert UTC time smartly.
        current_xchange.time    = Time.strptime(result['Time'], '%H:%M%p').strftime('%H:%M')
        current_xchange.ask     = result['Ask']
        current_xchange.bid     = result['Bid']
        current_xchange.change  = current_xchange.rate - current_xchange.previous.rate unless current_xchange.previous.nil?
        current_xchange.save unless current_xchange.registered?
      end
    end
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
      OrderedKey.import [:outer_id], xchange_orderedkeys, validate: false
    end
  end

  def update_change
    ActiveRecord::Base.transaction do
      xchanges_updated = []
      xchanges_joined_previous = Xchange.joined_previous.all
      xchanges_joined_previous.find_each do |xchange|
        xchange.change = xchange.attributes['xchanges.rate - xchanges_current_previous.rate'] || 0.0
        # OPTIMIZE: "on_duplicate_key_update" option for bulk update is only available on mysql.
        #   Use ActiveRecord "save" method instead.
        ['mysql'].include?($DB_CONFIG[$ENV]['adapter']) ? xchanges_updated << xchange : xchange.save
      end
      if ['mysql'].include?($DB_CONFIG[$ENV]['adapter'])
        updated_xchanges_maped  = xchanges_updated.map { |xchange| [xchange.id, xchange.change] }
        Xchange.import [:id, :change], updated_xchanges_maped, on_duplicate_key_update: [:id]
      end
      OrderedKey.delete_all
    end
  end
end
