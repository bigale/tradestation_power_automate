let $home := Q{org.basex.util.Prop}HOMEDIR() || "webapp\static\ts\"                  
let $folders :=
  let $root := $home || 'results\'
  for $file in file:list($root, false(), '*')
  let $path := $root || $file
  (: where file:size($path) = 0 :)
  order by file:last-modified($path) descending
  return $file

return db:add('results',$home || 'results\' || replace($folders[1],'\\',''), $folders[1], map{'parser':'csv'})