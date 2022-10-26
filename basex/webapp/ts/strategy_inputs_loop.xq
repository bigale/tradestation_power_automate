for $strat at $pos in db:get("SelectedStrategies", "SelectedStrategies")/items/text

  let $interval := (5,15)

  (: let $symlist := db:get("FuturesMarginRates_TradeStation", "Futures Margin Rates _ TradeStation.html")//tr/th[not(contains(.,'EUR'))]/../..//tr[@style="height: 23px;"]/td[2]/text() :) 

  (: let $securities_block := :) 
    (: for $symbol in (db:get("symbol_micro_futures_only", "symbol_micro_futures.csv")/csv/record, :)
      (: db:get("symbol_micro_futures", "symbol_micro_futures.csv")/csv/record) :)
      (: where $symbol/Description[contains(.,"ini")] :)
      (: and $symbol/Description[not(contains(.,"icro"))] :)
      (: and $symbol/Symbol[contains(.,".D")] :)
      (: and $symbol/Symbol[contains(.,"@")] :)
      (: and $symbol/Symbol[not(contains(.,"22"))] :)
      (: and $symbol/Symbol[not(contains(.,"0"))] :)
      (: and $symbol/Symbol[not(contains(.,"TF"))] :)   
      (: where some $item in $symlist :)
      (: satisfies(matches($item,$symbol/Symbol)) :)
  
  let $securities_block :=
    for $symbol in db:get("symbols", "symbols")/csv/record
    where $symbol/Symbol/text()[not(matches(.,'[0-9]'))]

      
      (: let $s := $symbol/csv/record/Symbol :)
      (: order by $symbol/Symbol :)
      (: group by $s :)
     
      
      let $interval_block := 
      for $quantity in $interval return
            <Security>
               <Symbol>{$symbol/Symbol}</Symbol>
                 <Interval>
                    <ChartType>Bar</ChartType>
                    <Compression>Minute</Compression>
                    <Quantity>{$quantity}</Quantity>
                 </Interval>         
               <History>
                  <LastDate>{tokenize(string(current-date()),'-..:')[1]}</LastDate>
                  <DaysBack>{$quantity * 10}</DaysBack>
               </History>       
            </Security>
    
    return $interval_block
  
  
  let $strategy_block := 
    for $item in db:get("strategies")[position() eq $pos]
      let $name := db:path($item)
      let $entry := $item//text()
    
      return    
        <Strategy>
           <Name>{tokenize($name,".txt")[1]}</Name>
           <Inputs>
            {
              for $line in $entry[contains(.,"(")]
                where $line >> $entry[.="Inputs:"]
                and $line << $entry[.="Vars:"]
                let $input := normalize-space(tokenize($line,"\(")[1])
                let $v1 := tokenize($line,"\(")[2]
                let $v2 := tokenize($v1,"\)")[1]
                
                let $default_inputs := ('LongOnly','NumContracts','TimeSessionBegin','TimeSessionEnd'
                ,'BarSize','BegDate','EndDate', 'GapThresh')
                
                let $fixed_inputs := ('TimeSessionBegin','TimeSessionEnd','BarSize')
                
                return 
                  if(string-length($v2) < 5 and  $input[not(.=($default_inputs))]) then
                    let $constant := if ($v2[contains(.,'-')]) then -1 else 1
                    
                    let $calculated_start_value := 
                      if ($v2[contains(.,'.')]) then number($v2) div 10
                      else if ($v2='0') then 0                     
                      else round(number($v2) - (number($v2) * .8) * $constant)
                      
                    let $calculated_stop_value := 
                      if ($v2[contains(.,'.')]) then 1 - number($v2) div 10
                      else if ($v2='0') then 1  
                      else round(number($v2) + (number($v2) * .8) * $constant)
                      
                    let $calculated_increment_value := 
                      if ($v2[contains(.,'.')]) then number($v2) div 10
                      else if ($calculated_stop_value - $calculated_start_value < 21) then 1
                      else if ($v2='0') then 1  
                      else 2
                                          
                    return  
                      if($input = 'Trim') then
                        <OptRange>
                           <Name>{$input}</Name>
                           <Start>0</Start>
                           <Stop>1</Stop>
                           <Step>.1</Step>
                           <Type>Numeric</Type>
                        </OptRange>                      
                      else
                        <OptRange>
                           <Name>{$input}</Name>
                           <Start>{$calculated_start_value}</Start>
                           <Stop>{$calculated_stop_value}</Stop>
                           <Step>{$calculated_increment_value}</Step>
                           <Type>Numeric</Type>
                        </OptRange>
                        
                    else if ($input[.=($fixed_inputs)]) then
                      if($input='BarSize') then
                         <Input>
                           <Name>{$input}</Name>
                           <Value> {($securities_block//Quantity)[1]/text()}</Value>
                           <Type>Numeric</Type>
                        </Input>
                      else if($input='TimeSessionBegin') then
                         <Input>
                           <Name>{$input}</Name>
                           <Value>715</Value>
                           <Type>Numeric</Type>
                        </Input>
                      else if($input='TimeSessionEnd') then
                         <Input>
                           <Name>{$input}</Name>
                           <Value>1615</Value>
                           <Type>Numeric</Type>
                        </Input>          
                                                              
            }
           
           </Inputs>
        </Strategy>
  
  let $commission_amount := 1.50
  
  let $final := for $security in $securities_block return
    <Job>
      <Method>Genetic</Method>
      <Securities>{$security}</Securities>
      <Strategies>{$strategy_block}</Strategies>
      <Settings>
        <GeneralOptions>
          <MaxBarsBack>300</MaxBarsBack>
        </GeneralOptions>
        <CostsAndCapital>
          <CommissionMode>FixedPerTrade</CommissionMode>
          <CommissionAmount>{$commission_amount}</CommissionAmount>
          <Capital>3000</Capital>
        </CostsAndCapital>
        <GeneticOptions> 
          <PopulationSize>100</PopulationSize>
          <Generations>40</Generations>
        </GeneticOptions>
        <ResultOptions>
         <NumTestsToKeep>30</NumTestsToKeep>
        </ResultOptions>
     </Settings>
    </Job>
  
    return $final
      (: db:add('Jobs',<items>{$final}</items>,'Jobs') :)
