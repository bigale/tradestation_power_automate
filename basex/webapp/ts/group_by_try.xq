for $item in db:get("named_results", "named_results")/updates/record
let $symbol := $item/name
group by $symbol
return $item[1]