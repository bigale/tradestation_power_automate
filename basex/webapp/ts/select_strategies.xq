for $strategy in db:get("strategies")

where $strategy[not(contains(.,"WFO"))]
(: where $strategy[contains(.,"Daily")] :)
and $strategy[not(contains(.,"Daily Angle"))]
    return
      db:add('SelectedStrategies',<items>{$strategy}</items>,'SelectedStrategies')