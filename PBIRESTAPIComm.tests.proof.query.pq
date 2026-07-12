section UnitTestingUnitTests;

Fact = (_subject as text, _expected, _actual) as record =>
    let
        expected = if Value.Is(_expected, Function.Type) then try _expected() else try _expected,
        actual = if Value.Is(_actual, Function.Type) then try _actual() else try _actual,
        isSuccess = if expected[HasError] or actual[HasError] then false else expected[Value] = actual[Value],
        details =
            if expected[HasError] then "Expected error"
            else if actual[HasError] then (try actual[Error][Message] otherwise "Actual error")
            else ""
    in
        [Result = if isSuccess then "Success" else "Failure", Notes = _subject, Details = details];

shared MyExtension.UnitTest =
[
    Source = PBIRESTAPIComm.FunctionCatalog(),
    
    DatasetTestID = Environment.FeatureSwitch("DatasetTestID"),
    
    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,
    
    ExecuteQuery = _GetFunction("ExecuteQuery"),
    ExecuteDaxQueries = _GetFunction("ExecuteDaxQueries"),
    
    DateDimQuery = "EVALUATE TOPN(10,DateDim,DateDim[Date],DESC)",
    
    // Get JSON baseline
    ExecuteQueryResult = Json.Document(ExecuteQuery(DatasetTestID, DateDimQuery)),
    ExecuteQueryRows = ExecuteQueryResult[results]{0}[tables]{0}[rows],
    ExecuteQueryColumns = List.Accumulate(
        ExecuteQueryRows,
        {},
        (state, row) => List.Distinct(List.Combine({state, Record.FieldNames(row)}))
    ),
    
    // Get Arrow candidate
    ExecuteDaxQueriesResult = ExecuteDaxQueries(DatasetTestID, DateDimQuery),
    ExecuteDaxQueriesColumns = Table.ColumnNames(ExecuteDaxQueriesResult),
    ExecuteDaxQueriesRows = Table.ToRecords(ExecuteDaxQueriesResult),
    
    // Cell-by-cell comparison
    RowMatches = List.Transform(
        List.Positions(ExecuteQueryRows),
        (idx) =>
            let
                jsonRow = ExecuteQueryRows{idx},
                arrowRow = if idx < List.Count(ExecuteDaxQueriesRows) then ExecuteDaxQueriesRows{idx} else null,
                cellChecks = if arrowRow = null then {} else List.Transform(
                    ExecuteQueryColumns,
                    (col) =>
                        let
                            jsonVal = if Record.HasFields(jsonRow, col) then Record.Field(jsonRow, col) else null,
                            arrowVal = if Record.HasFields(arrowRow, col) then Record.Field(arrowRow, col) else null,
                            match = (jsonVal = arrowVal) or (jsonVal = null and arrowVal = null)
                        in
                            [Column = col, JSON = jsonVal, Arrow = arrowVal, Match = match]
                ),
                allMatch = List.AllTrue(List.Transform(cellChecks, each _[Match]))
            in
                [RowIndex = idx + 1, AllMatch = allMatch, CellChecks = cellChecks]
    ),
    
    AllRowsMatch = List.AllTrue(List.Transform(RowMatches, each _[AllMatch])),
    
    facts = {
        Fact("ExecuteQuery Should Return 10 Rows", 10, List.Count(ExecuteQueryRows)),
        Fact("ExecuteDaxQueries Should Return 10 Rows", 10, List.Count(ExecuteDaxQueriesRows)),
        Fact("Column Counts Should Match", List.Count(ExecuteQueryColumns), List.Count(ExecuteDaxQueriesColumns)),
        Fact("Column Names Should Match", ExecuteQueryColumns, ExecuteDaxQueriesColumns),
        Fact("All Rows Should Match Cell-by-Cell", true, AllRowsMatch),
        Fact("Row 1 Should Match", true, RowMatches{0}[AllMatch]),
        Fact("Row 2 Should Match", true, RowMatches{1}[AllMatch]),
        Fact("Row 3 Should Match", true, RowMatches{2}[AllMatch]),
        Fact("Row 4 Should Match", true, RowMatches{3}[AllMatch]),
        Fact("Row 5 Should Match", true, RowMatches{4}[AllMatch]),
        Fact("Row 6 Should Match", true, RowMatches{5}[AllMatch]),
        Fact("Row 7 Should Match", true, RowMatches{6}[AllMatch]),
        Fact("Row 8 Should Match", true, RowMatches{7}[AllMatch]),
        Fact("Row 9 Should Match", true, RowMatches{8}[AllMatch]),
        Fact("Row 10 Should Match", true, RowMatches{9}[AllMatch])
    },
    
    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];

