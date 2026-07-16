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

    DateTimeProbeQuery = "EVALUATE ROW(""ProbeSet"", ""A"", ""NowUtc"", UTCNOW())" & "#(lf)" & "EVALUATE ROW(""ProbeSet"", ""B"", ""NowUtc"", UTCNOW())",

    // Connector returns a LIST of tables — one per EVALUATE result set.
    GetProbeList = () => ExecuteDaxQueriesInGroup(GroupTestID, DatasetTestID, DateTimeProbeQuery),

    HasCol = (t as table, name as text) as logical =>
        let cols = Table.ColumnNames(t) in List.Contains(cols, name) or List.Contains(cols, "[" & name & "]"),

    ProbeSetValue = (t as table) as text =>
        let
            col = if List.Contains(Table.ColumnNames(t), "ProbeSet") then "ProbeSet" else "[ProbeSet]"
        in
            Text.From(Table.Column(t, col){0}),

    facts =
    {
        Fact("ExecuteDaxQueriesInGroup Should Be a Function", true, Value.Is(ExecuteDaxQueriesInGroup, Function.Type)),
        Fact("DateTime Multi-Evaluate Probe Should Return a List", true, () => Value.Is(GetProbeList(), type list)),
        Fact("DateTime Multi-Evaluate Probe Should Return 2 Result Sets", 2, () => List.Count(GetProbeList())),
        Fact("DateTime Multi-Evaluate Probe Item 0 Should Be a 1-Row Table", 1, () => Table.RowCount(GetProbeList(){0})),
        Fact("DateTime Multi-Evaluate Probe Item 1 Should Be a 1-Row Table", 1, () => Table.RowCount(GetProbeList(){1})),
        Fact("DateTime Multi-Evaluate Probe Item 0 Should Have ProbeSet Column", true, () => HasCol(GetProbeList(){0}, "ProbeSet")),
        Fact("DateTime Multi-Evaluate Probe Item 0 Should Have NowUtc Column", true, () => HasCol(GetProbeList(){0}, "NowUtc")),
        Fact("DateTime Multi-Evaluate Probe Item 0 ProbeSet Should Be A", "A", () => ProbeSetValue(GetProbeList(){0})),
        Fact("DateTime Multi-Evaluate Probe Item 1 ProbeSet Should Be B", "B", () => ProbeSetValue(GetProbeList(){1}))
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
