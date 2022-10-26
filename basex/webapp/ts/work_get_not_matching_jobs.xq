let $path := for $item in db:get("results")
return db:path($item)

for $item in db:get("jobs", "Jobs")/items/Job
let $symbol := $item/Securities/Security/Symbol/text()
let $quantity := $item/Securities/Security/Interval/Quantity/text()
let $strategy_name := $item/Strategies/Strategy/Name/text()


return ($item,every $item in $path
satisfies(not(matches($item,'.*' || $symbol || '.*' || $quantity || '.*' || $strategy_name)))
)
