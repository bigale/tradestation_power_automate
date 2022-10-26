let $home := Q{org.basex.util.Prop}HOMEDIR() || "webapp\static\ts\"
let $res := serialize(db:get("named_results", "named_results")/updates,  map {
    'method': 'csv',
    'csv': map { 'header': 'yes', 'separator': ',' }
  })
  
return file:write($home || "res.csv",$res)