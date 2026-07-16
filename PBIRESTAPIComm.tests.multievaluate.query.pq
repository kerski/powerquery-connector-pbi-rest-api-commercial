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

    GroupTestID = Environment.FeatureSwitch("GroupTestID"),
    DatasetTestID = Environment.FeatureSwitch("DatasetTestID"),

    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,

    ExecuteDaxQueries = _GetFunction("ExecuteDaxQueries"),
    ExecuteDaxQueriesInGroup = _GetFunction("ExecuteDaxQueriesInGroup"),

    // Multi-EVALUATE query: two EVALUATE statements in a single query string.
    // The executeDaxQueries endpoint returns one Arrow IPC stream per EVALUATE
    // result. The connector returns a LIST of tables, one per result set, each
    // preserving its own schema:
    //   item 0 = 5 rows from TOPN(5, DateDim, ..., ASC)
    //   item 1 = 1 row  from ROW("Count", COUNTROWS(DateDim))
    MultiEvalQuery = "EVALUATE TOPN(5, DateDim, DateDim[Date], ASC)" & "#(lf)EVALUATE ROW(""Count"", COUNTROWS(DateDim))",

    // --- InGroup helpers ---
    GetMultiEvalInGroup = () => ExecuteDaxQueriesInGroup(GroupTestID, DatasetTestID, MultiEvalQuery),

    // --- No-group helpers (My workspace endpoint) ---
    GetMultiEval = () => ExecuteDaxQueries(DatasetTestID, MultiEvalQuery),

    facts =
    {
        Fact("ExecuteDaxQueries Should Be a Function", true, Value.Is(ExecuteDaxQueries, Function.Type)),
        Fact("ExecuteDaxQueriesInGroup Should Be a Function", true, Value.Is(ExecuteDaxQueriesInGroup, Function.Type)),

        // --- ExecuteDaxQueriesInGroup multi-evaluate (list of tables) ---
        Fact(
            "ExecuteDaxQueriesInGroup Multi-Evaluate Should Return a List",
            true,
            () => Value.Is(GetMultiEvalInGroup(), type list)
        ),
        Fact(
            "ExecuteDaxQueriesInGroup Multi-Evaluate Should Return 2 Result Sets",
            2,
            () => List.Count(GetMultiEvalInGroup())
        ),
        Fact(
            "ExecuteDaxQueriesInGroup Multi-Evaluate Item 0 Should Be a Table",
            true,
            () => Value.Is(GetMultiEvalInGroup(){0}, type table)
        ),
        Fact(
            "ExecuteDaxQueriesInGroup Multi-Evaluate Item 0 (TOPN 5) Should Have 5 Rows",
            5,
            () => Table.RowCount(GetMultiEvalInGroup(){0})
        ),
        Fact(
            "ExecuteDaxQueriesInGroup Multi-Evaluate Item 1 (COUNTROWS) Should Have 1 Row",
            1,
            () => Table.RowCount(GetMultiEvalInGroup(){1})
        ),

        // --- ExecuteDaxQueries multi-evaluate (My workspace) ---
        Fact(
            "ExecuteDaxQueries Multi-Evaluate Should Return a List",
            true,
            () => Value.Is(GetMultiEval(), type list)
        ),
        Fact(
            "ExecuteDaxQueries Multi-Evaluate Should Return 2 Result Sets",
            2,
            () => List.Count(GetMultiEval())
        ),
        Fact(
            "ExecuteDaxQueries Multi-Evaluate Item 0 (TOPN 5) Should Have 5 Rows",
            5,
            () => Table.RowCount(GetMultiEval(){0})
        ),
        Fact(
            "ExecuteDaxQueries Multi-Evaluate Item 1 (COUNTROWS) Should Have 1 Row",
            1,
            () => Table.RowCount(GetMultiEval(){1})
        )
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
