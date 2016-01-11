require 'csv'
require 'chronic'

original = CSV.read('tech_crunch.csv', headers: true, converters: :all)
cleaned = CSV.open('tech_crunch_cleaned.csv', 'w', write_headers: true, headers: original.headers)
date_fields = ['fundedDate']
original.each do |row|
  data_hash = row.map do |field, value|
    if date_fields.include? field
      [ field, Chronic.parse(value).to_s ]
    else
      [ field, value ]
    end
  end
  cleaned << data_hash.map { |a| a[1] }
end
cleaned.close
