require 'httparty'
require 'yaml'
require 'json'
require 'pry'
require 'csv'
require_relative 'util_constants'
require_relative 'generic_mapping'
require_relative 'http_client'
require_relative 'query_builder'

class EsClient

  include GenericMapping
  include QueryBuilder

  attr_reader :index_url, :doc_type, :field_count

  def initialize(config)
    @index_url = config['index_url']
    @doc_type = config['doc_type']
    @field_count = config['field_count']
    HttpClient.base_uri config['es_host']
  end

  def create_index
    res = HttpClient.head(index_url)
    HttpClient.delete(index_url) if res.code == 200
    res = HttpClient.post(index_url, body: index_settings.to_json)
    raise "Could not create index" if res.code != 200
  end

  def create_mapping
    mapping = get_mapping_properties
    res = HttpClient.put("#{index_url}/_mapping/#{doc_type}", body: mapping.to_json)
    raise "Could not create mapping #{res.body}" unless res.code == 200
  end

  def populate_data(parser, grid_id)
    parser.each_row do |row|
      data_row = {}
      row.to_h.values.each_with_index do |value, i|
        column_es_type = get_es_field_type(value.class.to_s)
        data_row["c#{i}-#{column_es_type}"] = value
      end
      res = HttpClient.post("#{index_url}/#{doc_type}?routing=#{grid_id}", body: data_row.to_json)
      raise "Data index failure #{res.to_s}" unless (res.code == 201 || res.code == 200)
    end
  end

=begin
  def search(query_string, grids)
    query_request = multi_match_query_json(query_string, grids)
    res = HttpClient.post("#{index_url}/#{doc_type}?routing=#{grids.join(',')}", body: query_request.to_json)
    raise "Query request failure #{res.to_s}" unless (res.code == 201 || res.code == 200)
    binding.pry
  end
=end

  def analyzer
    UtilConstants::ANALYZER_NAME
  end

  def index_settings
    {
      "settings" => {
        "number_of_shards" => 5,
        "number_of_replicas" => 0,
        "analysis" => {
          "filter" => UtilConstants::NGRAM_FILTER,
          "analyzer" => UtilConstants::ANALYZER
        }
      }
    }
  end
end
