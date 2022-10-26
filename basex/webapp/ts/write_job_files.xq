(:  :)
let $home := Q{org.basex.util.Prop}HOMEDIR() || "webapp\static\ts\"
let $dt := replace(string(current-dateTime()),':','_')

let $mkdir := file:create-dir($home || 'jobs\' || $dt)
let $mkdir := file:create-dir($home || 'results\' || $dt)

let $path := for $item in db:get("results")
return db:path($item)

for $item in db:get("jobs", "Jobs")/items/Job
let $symbol := $item/Securities/Security/Symbol/text()
let $quantity := $item/Securities/Security/Interval/Quantity/text()
let $strategy_name := $item/Strategies/Strategy/Name/text()
where every $item in $path
satisfies(not(matches($item,'.*' || $symbol || '.*' || $quantity || '.*' || $strategy_name)))

return (
  $item,
  file:write($home || 'jobs\' || $dt || '\opt_data_' || $symbol || '_' || $quantity || '_ min_' || $strategy_name || '.xml', $item)
)