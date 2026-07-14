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
    
    ExecuteDaxQueries = _GetFunction("ExecuteDaxQueries"),
    
    DateDimQuery = "EVALUATE TOPN(10,DateDim,DateDim[Date],DESC)",
    
    // Execute query through connector's Arrow IPC parser
    ExecuteDaxQueriesResult = ExecuteDaxQueries(DatasetTestID, DateDimQuery),
    
    // Verify it's a table
    IsTable = Value.Is(ExecuteDaxQueriesResult, type table),
    
    // Extract table metadata
    ColumnNames = if IsTable then Table.ColumnNames(ExecuteDaxQueriesResult) else {},
    ColumnCount = List.Count(ColumnNames),
    RowCount = if IsTable then Table.RowCount(ExecuteDaxQueriesResult) else 0,
    
    // Convert to records for inspection
    Rows = if IsTable and RowCount > 0 then Table.ToRecords(ExecuteDaxQueriesResult) else {},
    
    // Get first 3 rows for display
    SampleRows = if List.Count(Rows) >= 3 then {Rows{0}, Rows{1}, Rows{2}} else Rows,
    
    // Create display record showing actual data
    ProofRecord = [
        TestName = "ExecuteDaxQueries Arrow IPC Parser - DateDim TOPN10 Proof",
        TestQuery = DateDimQuery,
        ParsedSuccessfully = IsTable,
        ColumnCount = ColumnCount,
        ColumnNames = Text.Combine(ColumnNames, ", "),
        RowCount = RowCount,
        SampleRow1 = if List.Count(Rows) > 0 then Rows{0} else null,
        SampleRow2 = if List.Count(Rows) > 1 then Rows{1} else null,
        SampleRow3 = if List.Count(Rows) > 2 then Rows{2} else null,
        AllRows = Rows
    ],
    
    // Create test facts
    facts = {
        Fact("Should Return a Table", true, IsTable),
        Fact("Should Return 5 Columns", 5, ColumnCount),
        Fact("Should Return 10 Rows", 10, RowCount),
        Fact("Should Have DateID Column", true, List.Contains(ColumnNames, "DateDim[DateID]")),
        Fact("Should Have Date Column", true, List.Contains(ColumnNames, "DateDim[Date]")),
        Fact("Should Have DateKey Column", true, List.Contains(ColumnNames, "DateDim[DateKey]")),
        Fact("Should Have MonthYearSort Column", true, List.Contains(ColumnNames, "DateDim[MonthYearSort]")),
        Fact("Should Have Month Year Column", true, List.Contains(ColumnNames, "DateDim[Month Year]")),
        Fact("Row 1 Should Have DateKey Text Value", true, Record.HasFields(Rows{0}, "DateDim[DateKey]") and Value.Is(Record.Field(Rows{0}, "DateDim[DateKey]"), type text)),
        Fact("Row 1 Should Have Month Year Text Value", true, Record.HasFields(Rows{0}, "DateDim[Month Year]") and Value.Is(Record.Field(Rows{0}, "DateDim[Month Year]"), type text))
    },
    
    // Return results with proof record for inspection
    results = Table.FromRecords({ProofRecord}),
    testResults = Table.ReverseRows(Table.FromRecords(facts)),
    failedTests = Table.SelectRows(testResults, each Text.StartsWith([Result], "F")),
    
    // Final output: proof record with embedded data and test results
    output = [
        ProofData = results,
        TestResults = testResults,
        FailedTests = failedTests,
        ActualDataTable = ExecuteDaxQueriesResult
    ],
    
    finalTable = Table.FromRecords({output})
][finalTable];
