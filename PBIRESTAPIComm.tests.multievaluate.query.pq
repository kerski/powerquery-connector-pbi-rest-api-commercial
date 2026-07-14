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
    // result, concatenated end-to-end.  ArrowParseStream continues past each
    // EOS marker and Table.Combine merges the result tables.
    //
    // Combined table shape:
    //   5 rows from TOPN(5, DateDim, ..., ASC) — DateDim columns present, [Count] null
    //   1 row  from ROW("Count", COUNTROWS(DateDim)) — [Count] present, DateDim cols null
    //   Total: 6 rows
    MultiEvalQuery = "EVALUATE TOPN(5, DateDim, DateDim[Date], ASC)" & "#(lf)EVALUATE ROW(""Count"", COUNTROWS(DateDim))",

    // --- InGroup helpers ---
    GetMultiEvalInGroup = () => ExecuteDaxQueriesInGroup(GroupTestID, DatasetTestID, MultiEvalQuery),
    GetMultiEvalRowsInGroup = () => Table.ToRows(GetMultiEvalInGroup()),

    // --- No-group helpers (My workspace endpoint) ---
    GetMultiEval = () => ExecuteDaxQueries(DatasetTestID, MultiEvalQuery),
    GetMultiEvalRows = () => Table.ToRows(GetMultiEval()),

    facts =
    {
        Fact("ExecuteDaxQueries Should Be a Function", true, Value.Is(ExecuteDaxQueries, Function.Type)),
        Fact("ExecuteDaxQueriesInGroup Should Be a Function", true, Value.Is(ExecuteDaxQueriesInGroup, Function.Type)),

        // --- ExecuteDaxQueriesInGroup multi-evaluate ---
        Fact(
            "ExecuteDaxQueriesInGroup Multi-Evaluate Should Return 6 Rows Total (5 TOPN + 1 COUNTROWS)",
            6,
            () => List.Count(GetMultiEvalRowsInGroup())
        ),
        Fact(
            "ExecuteDaxQueriesInGroup Multi-Evaluate Should Return a Table (not an error)",
            true,
            () => Value.Is(GetMultiEvalInGroup(), type table)
        ),
        Fact(
            "ExecuteDaxQueriesInGroup Multi-Evaluate Combined Table Should Have At Least 1 Column",
            true,
            () => Table.ColumnCount(GetMultiEvalInGroup()) >= 1
        ),

        // --- ExecuteDaxQueries multi-evaluate (My workspace) ---
        Fact(
            "ExecuteDaxQueries Multi-Evaluate Should Return 6 Rows Total (5 TOPN + 1 COUNTROWS)",
            6,
            () => List.Count(GetMultiEvalRows())
        ),
        Fact(
            "ExecuteDaxQueries Multi-Evaluate Should Return a Table (not an error)",
            true,
            () => Value.Is(GetMultiEval(), type table)
        ),
        Fact(
            "ExecuteDaxQueries Multi-Evaluate Combined Table Should Have At Least 1 Column",
            true,
            () => Table.ColumnCount(GetMultiEval()) >= 1
        )
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
