for $symbol in (db:get("symbol_micro_futures_only", "symbol_micro_futures.csv")/csv/record,
db:get("symbol_micro_futures", "symbol_micro_futures.csv")/csv/record)

where $symbol/Description[contains(.,"ini")]
and $symbol/Description[not(contains(.,"icro"))]
(: and $symbol/Symbol[contains(.,".D")] :)
and $symbol/Symbol[contains(.,"@")]
and $symbol/Symbol[not(contains(.,"22"))]

let $s := $symbol/Symbol
order by $symbol/Symbol
group by $s
return <Symbol>{$s}</Symbol>
