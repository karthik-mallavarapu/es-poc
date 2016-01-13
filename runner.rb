require_relative 'lib/es_client'
require_relative 'lib/data_parser'
require 'yaml'

# Default ES host name and doc type.
config = YAML.load_file('config.yml')
# User 1..create new index, mapping and populate data
config['index_url'] = '/user1'
client = EsClient.new(config)
client.create_index
client.create_mapping
client.populate_data( DataParser.new('sample_data/user1/listings1.csv'),
  'listing1' )
client.populate_data( DataParser.new('sample_data/user1/listings2.csv'),
  'listing2' )
client.populate_data( DataParser.new('sample_data/user1/listings3.csv'),
  'listing3' )
puts "User1: Index and Mapping created. Data uploaded"
# User 2..create new index, mapping and populate data
config['index_url'] = '/user2'
client = EsClient.new(config)
client.create_index
client.create_mapping
client.populate_data( DataParser.new('sample_data/user2/sales.csv'),
                     'sales')
client.populate_data( DataParser.new('sample_data/user2/funding.csv'), 
  'funding' )
puts "User2: Index and Mapping created. Data uploaded"

# User 3..create new index, mapping and populate data
config['index_url'] = '/user3'
client = EsClient.new(config)
client.create_index
client.create_mapping
client.populate_data( DataParser.new('sample_data/user3/products.csv'), 
  'products' )
client.populate_data( DataParser.new('sample_data/user3/purchases.csv'), 
  'purchases' )
client.populate_data( DataParser.new('sample_data/user3/discounts.csv'), 
  'discounts' )
puts "User3: Index and Mapping created. Data uploaded"
