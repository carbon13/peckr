# encoding: utf-8
class YQLCollector
  attr_accessor :where_clause

  def initialize(table_name, where_clause = nil)
    self.table_name = table_name
    self.where_clause = where_clause
  end

  def table_name=(table_name)
    @table_name = (table_name.is_a? String) ? table_name : table_name.to_s
  end

  def where_in(column_name, values, records_per_request = 200)
    @json_results_array = []
    column_name = (column_name.is_a? String) ? column_name : column_name.to_s
    values.each_slice(records_per_request).to_a.each do |sliced_values|
      self.where_clause = "#{column_name} IN ('#{sliced_values.join("', '")}')"
      @json_results_array << where
    end
    @json_results_array.flatten
  end

  def where(where_clause = nil)
    self.where_clause = where_clause unless where_clause.nil?
    yql_query = "https://query.yahooapis.com/v1/public/yql?q=#{to_yql}&format=json&diagnostics=true&env=store%3A%2F%2Fdatatables.org%2Falltableswithkeys"
    yql_query_parsed = Addressable::URI.parse(yql_query)
    json_results = JSON.parser.new(Net::HTTP.get(yql_query_parsed)).parse['query']['results'].values
  end

  def to_yql
    plain_yql = "SELECT * FROM #{@table_name} WHERE #{@where_clause}"
    encoded_yql = URI.encode_www_form_component(plain_yql).gsub('+', '%20').gsub('%28', '(').gsub('%29', ')')
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
end
