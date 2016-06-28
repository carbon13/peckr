# encoding: utf-8
class EventsCollector
  def query_and_store
    store(query)
  end

  def query
    parsed_results = []
    # target_uris = HTMLsSource.all.pluck(:link)
    target_uris = %w(http://fx.minkabu.jp/indicators/calendar)
    target_uris.each do |uri|
      parsed_results << Nokogiri::XML(open(uri, redirect: true))
    end
    parsed_results
  end

  def store(results)
    return if results.nil?
    results.each do |result|
      store_events(result)
    end
  end

  def store_events(result)
    @previous_row_date = ''
    event_table = result.xpath("//table[@class='tbl tblYoko']")
    event_table.xpath(".//tr[@class='indicator_announcement']").each do |node|
      event_datetime               = datetime(node)
      event_country_id             = country_id(node)
      event_indicator              = indicator(node)
      event                        = Event.find_or_create_by(datetime: event_datetime, country_id: event_country_id, indicator: event_indicator)
      event.impact_factor          = impact_factor(node)
      event.previous_value         = previous_value(node)
      event.estimated_value        = estimated_value(node)
      event.previous_impact_usdjpy = previous_impact_usdjpy(node)
      event.save
      @previous_row_date = event.date
    end
  end

  def datetime(node)
    date_string = date_string_local(node)
    time_string = time_string_local(node)
    Time.strptime("#{date_string_local} #{time_string_local} +0900", '%Y-%m-%d %H:%M %z').utc
  end

  def date_string_local(node)
    # HACK: About class=cell00, source html structure was broken?
    date_string = node.xpath(".//td[contains(@class, 'cell00')]").first.try(:text).try(:match, /^\n.+\n/).try(:to_s).try(:gsub, /\n/, ' ').try(:strip) ||
                  @previous_row_date.strftime('%m/%d (%a)')
    date = Date.strptime(date_string, '%m/%d')
    date < (Date.today - 1.month) ? date.next_year.to_s : date.to_s
  end

  def time_string_local(node)
    faired_text(node.xpath(".//td[contains(@class, 'cell01')]"))
  end

  def date_nil?(node)
    node.xpath(".//td[contains(@class, 'cell00')]").first.nil?
  end

  def country_id(node)
    node.xpath(".//td[contains(@class, 'cell02')]").first.xpath('i').try(:attribute, 'class').try(:value).gsub(/^i-/, '').upcase
  end

  def indicator(node)
    faired_text(node.xpath(".//td[contains(@class, 'cell03')]"))
  end

  def impact_factor(node)
    node.xpath(".//td[contains(@class, 'cell04')]").first.xpath("i[@class='i-star']").try(:size) || 0
  end

  def previous_value(node)
    faired_text(node.xpath(".//td[contains(@class, 'cell05')]"))
  end

  def estimated_value(node)
    faired_text(node.xpath(".//td[contains(@class, 'cell06')]"))
  end

  def previous_impact_usdjpy(node)
    faired_text(node.xpath(".//td[contains(@class, 'cell07')]"))
  end

  def faired_text(node)
    node.first.try(:text).try(:gsub, /\n/, ' ').try(:strip)
  end
end
