let $home := Q{org.basex.util.Prop}HOMEDIR() || "webapp\static\ts\"
let $securities_block := 
for $symbol in (db:get("symbol_micro_futures_only", "symbol_micro_futures.csv")/csv/record,
db:get("symbol_micro_futures", "symbol_micro_futures.csv")/csv/record)
where $symbol/Description[contains(.,"icro")]
and $symbol/Symbol[contains(.,"@")]
and string-length($symbol/Symbol) < 5

(: and $symbol/Symbol[contains(.,".D")] :)
(: and $symbol/Symbol[not(contains(.,"22"))]
and $symbol/Symbol[not(contains(.,"23"))] :)

let $s := $symbol/Symbol
order by $symbol/Symbol
group by $s

return
      <Security>
         <Symbol>{$s}</Symbol>
         <Interval>
            <ChartType>Bar</ChartType>
            <Compression>Minute</Compression>
            <Quantity>15</Quantity>
         </Interval>
         <History>
            <LastDate>{tokenize(string(current-date()),'-..:')[1]}</LastDate>
            <DaysBack>90</DaysBack>
         </History>
      </Security>

let $strategy_block := 

for $item in db:get("strategies")
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
            ,'BarSize','BegDate','EndDate')
            
            
            return if(string-length($v2) < 5 and  $input[not(.=($default_inputs))]) then
            
            let $constant := if ($v2[contains(.,'-')]) then -1 else 1
            
            let $calculated_start_value := 
              if ($v2[contains(.,'.')]) then number($v2) div 10
              else round(number($v2) - (number($v2) * .8) * $constant)
              
            let $calculated_stop_value := 
              if ($v2[contains(.,'.')]) then 1 - number($v2) div 10
              else round(number($v2) + (number($v2) * .8) * $constant)
              
            let $calculated_increment_value := 
              if ($v2[contains(.,'.')]) then number($v2) div 10
              else 2
                                  
            return  
                <OptRange>
                   <Name>{$input}</Name>
                   <Start>{$calculated_start_value}</Start>
                   <Stop>{$calculated_stop_value}</Stop>
                   <Step>{$calculated_increment_value}</Step>
                   <Type>Numeric</Type>
                </OptRange>
          }
         </Inputs>
      </Strategy>

let $final :=  
<Job>
  <Method>Genetic</Method>
  <Securities>{$securities_block[position() lt 2]}</Securities>
  <Strategies>{$strategy_block[position() lt 2]}</Strategies>
  <Settings>
    <GeneralOptions>
      <MaxBarsBack>300</MaxBarsBack>
    </GeneralOptions>
    <CostsAndCapital>
      <CommissionMode>FixedPerTrade</CommissionMode>
      <CommissionAmount>1.50</CommissionAmount>
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
     (: <FitnessMetric>TSIndex</FitnessMetric> :)

return ($final,file:write($home || 'opt_data.xml', $final))

