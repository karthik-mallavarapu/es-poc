# Instantiate this class for parsing data and header fields. 
class DataParser
  # Adding a custom datetime converter for CSV files.
  CSV::Converters[:custom_date] = lambda do |s|
    begin
      DateTime.strptime(s, '%Y-%m-%d %H:%M:%S %Z')
    rescue ArgumentError
      s
    end
  end
  def initialize(filepath)
    @filepath = filepath
    @csv = CSV.open(filepath, headers: true, converters: CSV::Converters.keys + 
                    [:custom_date])
  end

  # Returns header fields as an array.
  def header_fields
    @csv.headers
  end

  # Expects a block. Iterates over all the data rows and calls the block for
  # each row.
  def each_row(&block)
    @csv.each do |row|
      yield(row) if block_given?
    end
  end

  def get_field_types
    data_row = @csv.first.to_h
    data_row.map { |field, value| [field, value.class.to_s] }.to_h
  end

  def filter_field_types(data_type)
    all_field_types = get_field_types
    all_field_types.select { |field, type| type == data_type }
  end
end
