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

    ExecuteDaxQueriesInGroup = _GetFunction("ExecuteDaxQueriesInGroup"),

    HasCol = (t as table, name as text) as logical =>
        let cols = Table.ColumnNames(t) in List.Contains(cols, name) or List.Contains(cols, "[" & name & "]"),

    // --- Case 1: MANY result sets that all share the SAME schema ---------------
    // Mirrors the real-world "test runner" pattern where every EVALUATE returns
    // rows with identical columns (TestName/Expected/Actual/Passed). The connector
    // returns a LIST of 5 single-row tables (one per result set).
    SameSchemaQuery =
        "EVALUATE ROW(""TestName"", ""t1"", ""Expected"", ""E1"", ""Actual"", ""A1"", ""Passed"", TRUE())" & "#(lf)" &
        "EVALUATE ROW(""TestName"", ""t2"", ""Expected"", ""E2"", ""Actual"", ""A2"", ""Passed"", TRUE())" & "#(lf)" &
        "EVALUATE ROW(""TestName"", ""t3"", ""Expected"", ""E3"", ""Actual"", ""A3"", ""Passed"", FALSE())" & "#(lf)" &
        "EVALUATE ROW(""TestName"", ""t4"", ""Expected"", ""E4"", ""Actual"", ""A4"", ""Passed"", TRUE())" & "#(lf)" &
        "EVALUATE ROW(""TestName"", ""t5"", ""Expected"", ""E5"", ""Actual"", ""A5"", ""Passed"", TRUE())",

    GetSameSchemaList = () => ExecuteDaxQueriesInGroup(GroupTestID, DatasetTestID, SameSchemaQuery),

    // --- Case 2: result sets with DIFFERENT schemas ---------------------------
    // Each EVALUATE returns different columns. The connector returns a LIST where
    // each item keeps its OWN schema (no column union across result sets).
    DiffSchemaQuery =
        "EVALUATE ROW(""Alpha"", 1, ""AlphaLabel"", ""a"")" & "#(lf)" &
        "EVALUATE ROW(""Beta"", 2)" & "#(lf)" &
        "EVALUATE ROW(""Gamma"", 3, ""GammaLabel"", ""g"", ""GammaFlag"", TRUE())",

    GetDiffSchemaList = () => ExecuteDaxQueriesInGroup(GroupTestID, DatasetTestID, DiffSchemaQuery),

    facts =
    {
        Fact("ExecuteDaxQueriesInGroup Should Be a Function", true, Value.Is(ExecuteDaxQueriesInGroup, Function.Type)),

        // Case 1: many same-schema result sets → list of 5 single-row tables
        Fact("Same-Schema Multi-Evaluate Should Return a List", true, () => Value.Is(GetSameSchemaList(), type list)),
        Fact("Same-Schema Multi-Evaluate Should Return 5 Result Sets", 5, () => List.Count(GetSameSchemaList())),
        Fact("Same-Schema Multi-Evaluate Item 0 Should Be a 1-Row Table", 1, () => Table.RowCount(GetSameSchemaList(){0})),
        Fact("Same-Schema Multi-Evaluate Item 4 Should Be a 1-Row Table", 1, () => Table.RowCount(GetSameSchemaList(){4})),
        Fact("Same-Schema Multi-Evaluate Item 0 Should Have TestName Column", true, () => HasCol(GetSameSchemaList(){0}, "TestName")),

        // Case 2: heterogeneous result sets → list where each item has its OWN schema
        Fact("Diff-Schema Multi-Evaluate Should Return a List", true, () => Value.Is(GetDiffSchemaList(), type list)),
        Fact("Diff-Schema Multi-Evaluate Should Return 3 Result Sets", 3, () => List.Count(GetDiffSchemaList())),
        Fact("Diff-Schema Item 0 Should Have Alpha (own schema)", true, () => HasCol(GetDiffSchemaList(){0}, "Alpha")),
        Fact("Diff-Schema Item 0 Should NOT Have Beta (no union)", false, () => HasCol(GetDiffSchemaList(){0}, "Beta")),
        Fact("Diff-Schema Item 1 Should Have Beta (own schema)", true, () => HasCol(GetDiffSchemaList(){1}, "Beta")),
        Fact("Diff-Schema Item 1 Should NOT Have Alpha (no union)", false, () => HasCol(GetDiffSchemaList(){1}, "Alpha")),
        Fact("Diff-Schema Item 2 Should Have Gamma (own schema)", true, () => HasCol(GetDiffSchemaList(){2}, "Gamma")),
        Fact("Diff-Schema Item 2 Should Have GammaFlag (own schema)", true, () => HasCol(GetDiffSchemaList(){2}, "GammaFlag"))
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
