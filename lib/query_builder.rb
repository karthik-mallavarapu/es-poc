module QueryBuilder

  def multi_match_query_json(query_string, grids)
    query = {
      "filtered" => {
        "query" => {
          "multi_match" => {
            "query" => query_string,
            "fields" => [*0...field_count].map { |i| "c#{i}-string" }
          },
          "filter" => {
            "terms" => {
              "_routing" => grids
            }
          }
        }
      }
    }
    return query
  end
end
