# Generate type mappings with ngram filters for strings.
require 'date'

module GenericMapping
  TYPES = { "numeric" => "long", 
            "decimal" => "float", 
            "string" => "string", 
            "date" => "date" }

  def get_mapping_properties
    mapping = {
      "properties" => {},
      "_routing" => {
        "required" => true
      }
    }
    properties = Hash.new
    field_count.times do |i|
      TYPES.each do |key, es_type|
        properties["c#{i}-#{key}"] = type_property(es_type)
      end
    end
    mapping["properties"] = properties
    return mapping
  end

  def get_es_field_type(ruby_type)
    case ruby_type
    when "Float"
      TYPES["decimal"]
    when "Fixnum", "Integer", "Bignum"
      TYPES["numeric"]
    when "Date", "DateTime"
      TYPES["date"]
    when "String"
      TYPES["string"]
    end
  end

  def type_property(data_type)
    property = Hash.new
    property["type"] = data_type
    if data_type == 'string'
      property["analyzer"] = string_analyzer
      property["fields"] = { "raw" => { "type" => "string",
                                        "index" => "not_analyzed" }}
    end
    property
  end

  def string_analyzer
    self.analyzer
  end
end
