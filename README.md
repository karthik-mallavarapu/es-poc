# es-poc
Elasticsearch PoC.

## Instructions
* Install rvm

```
\curl -sSL https://get.rvm.io | bash -s stable
```
* Install ruby

```      
rvm install 2.2.0
```

* Add appropriate configuration information to config.yml file. The configuration options are:
  * __es_host__ Elasticsearch host. Defaults to localhost:9200
  * __doc_type__ Name of the elasticsearch _type_. Defaults to document.
  * __field_count__ Maximum number of fields a document handles. Defaults to 30. 
  

* Execute runner.rb script. It creates indices for user1, user2 and user3. Adds a generic mapping with support for numeric, decimal, string and date fields. Populates data from csv files in sample_data directory.

```
bundle exec ruby runner.rb
```

## How It Works

* __lib/es_client.rb__ 
  * __create_index__ Creates a new elasticsearch index with ngram filter and analyzer settings.
  * __create_mapping__ Creates a mapping for doc type document. The mapping creates columns with support 4 types. For example, c0-string, c0-numeric, c0-decimal, c0-date, c1-string, c1-numeric, c1-decimal, c1-date and so on. The mapping also requires routing id to be provided with each request.  
  * __populate_data__ Expects the data parser object and grid id as arguments. For each row of data, data is indexed into appropriate columns based on their type. _Each http request includes a **routing** parameter with **grid id**_. Every row of data belonging to the same grid is routed to the same shard for efficiency. Consider the following example:
  ```
  Data of the form { 1234, 'Outliers', 'Malcom Gladwell', 05-08-2008} is indexed into c0-numeric, c1-string, c2-string, c3-date columns respectively.
  ```
* Multi-match query TODO
