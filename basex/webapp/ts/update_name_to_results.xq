(: 
The strategy name (with symbol_interval_strategy included) is part of the 
individual results filenames which are all imported into database.  
This name needs to be written as a field / column with all the results.
Then csv with strategy name column can be exported and used for charting and reporting.
 :)

let $updates := for $item in db:get("results")//record
let $name := db:path($item) 
let $n1 := tokenize($name,'Results – ')[2]
let $n2 := tokenize($n1,".csv")[1]

return $item update {
  insert node <name/> into .
} update {
  insert node $n2 into name
}

return db:put("named_results",<updates>{$updates}</updates>,"named_results")