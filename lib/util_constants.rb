module UtilConstants

  FILTER_NAME = 'ngram_filter'
  ANALYZER_NAME = 'ngram_analyzer'

  NGRAM_FILTER = {
    FILTER_NAME => {
      "type" => "ngram",
      "min_gram" => 2,
      "max_gram" => 7
    }
  }
  ANALYZER = {
    ANALYZER_NAME => {
      "type" => "custom",
      "tokenizer" => "standard",
      "filter" => [
        "lowercase",
        FILTER_NAME
      ]
    }
  }
end
