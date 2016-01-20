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
* __Multi-match query__
  * In order to restrict query search to specific grids, routing ids must be passed as URL parameters. In addition to that, request body must also have a filter on the field **_routing**. The following examples show how a multi match query can be constructed.
  ```
  POST /user1/document/_search?routing=listing1,listing2
  {
    "filter": {
        "terms": {
           "_routing": [
              "listing1", "listing2"
           ]
        }
    }
}

POST /user1/document/_search?routing=listing,listing2
{
    "query": {
        "multi_match": {
           "query": "residen",
           "fields": ["c0-string", "c1-string", "c2-string", "c3-string", "c15-string", "c16-string"]
        }
    }, 
    "filter": {
        "terms": {
           "_routing": [
              "listing1", "listing2"
           ]
        }
    }
}

POST /user1/document/_search?routing=listing
{
    "query": {
        "multi_match": {
           "query": 30.060614,
           "fields": ["c0-decimal", "c1-decimal", "c2-decimal", "c13-decimal", "c15-decimal", "c16-decimal"]
        }
    }, 
    "filter": {
        "terms": {
           "_routing": [
              "listing1"
           ]
        }
    }
}
```
* __Constant Score Query__
  * In order to get the count of document hits and field hits for each document, a constant score query in conjunction with a named query can be used. Constant score query gives a constant score of 1.0 for each hit (ignores scoring) and is thus quick and efficient. The response has a hits array, containing the document hits. Each document response further has a **matched_queries** field, listing the matching fields in that document. Document and field hits can be calculated by parsing the query response. The following is an example of a constant score query:
 ````
POST /user1/document/_search?routing=listing1,listing2
{
    "_source": false,
    "size": 100,
    "query": {
        "constant_score" : {
            "query" : {
                "bool": {
                    "disable_coord": true,
                    "should": [                        
                        {"match" : { "c3-numeric" : {"query": 498960, "_name": "c3-numeric"}}},
                        {"match" : { "c4-numeric" : {"query": 498960, "_name": "c4-numeric"}}},
                        {"match" : { "c5-numeric" : {"query": 498960, "_name": "c5-numeric"}}},
                        {"match" : { "c6-numeric" : {"query": 498960, "_name": "c6-numeric"}}},
                        {"match" : { "c7-numeric" : {"query": 498960, "_name": "c7-numeric"}}}
                    ]
                }                 
            }
        }
    }     
}
```
