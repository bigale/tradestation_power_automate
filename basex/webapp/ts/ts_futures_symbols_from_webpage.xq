let $home := Q{org.basex.util.Prop}HOMEDIR() || "webapp\static\ts\"    
let $file := db:get("FuturesMarginRates_TradeStation", "Futures Margin Rates _ TradeStation.html")//tr/th[not(contains(.,'EUR'))]/../..//tr[@style="height: 23px;"]/td[2]/text()
return file:write-text-lines($home || '/ts_futures_symbols_from_webpage.txt',$file)