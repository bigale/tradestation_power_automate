    for $symbol in db:get("symbols", "symbols")
    where $symbol/csv/record/Symbol/text()[not(matches(.,'[0-9]'))]
    return $symbol/csv/record/Symbol