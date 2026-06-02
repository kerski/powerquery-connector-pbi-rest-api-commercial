section UnitTestingUnitTests;

Fact = (_subject as text, _expected, _actual) as record =>
    let
        expected = try _expected,
        actual = try _actual,
        isSuccess = if expected[HasError] or actual[HasError] then false else expected[Value] = actual[Value],
        details =
            if expected[HasError] then "Expected error"
            else if actual[HasError] then "Actual error"
            else ""
    in
        [Result = if isSuccess then "Success" else "Failure", Notes = _subject, Details = details];

shared MyExtension.UnitTest =
[
    Source = PBIRESTAPIComm.FunctionCatalog(),

    GroupTestID = Environment.FeatureSwitch("GroupTestID"),
    DataflowTestID = Environment.FeatureSwitch("DataflowTestID"),
    DownstreamDataflowTestID = Environment.FeatureSwitch("DownstreamDataflowTestID"),

    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,

    GetDataflowDataSourcesInGroup = _GetFunction("GetDataflowDataSourcesInGroup"),
    GetDataflowInGroup = _GetFunction("GetDataflowInGroup"),
    GetDataflowTransactionsInGroup = _GetFunction("GetDataflowTransactionsInGroup"),
    GetDataflowsInGroup = _GetFunction("GetDataflowsInGroup"),
    GetUpstreamDataflowsInGroup = _GetFunction("GetUpstreamDataflowsInGroup"),

    facts =
    {
        Fact("GetDataflowInGroup Should Be a Function", true, Value.Is(GetDataflowInGroup, Function.Type)),
        Fact("GetDataflowInGroup Should Return Json with name property RawSourceExample", "RawSourceExample", Json.Document(GetDataflowInGroup(GroupTestID, DataflowTestID))[name]),

        Fact("GetDataflowDataSourcesInGroup Should Be a Function", true, Value.Is(GetDataflowDataSourcesInGroup, Function.Type)),
        Fact("GetDataflowDataSourcesInGroup Should Return Correct Metadata", "datasources", Text.AfterDelimiter(Json.Document(GetDataflowDataSourcesInGroup(GroupTestID, DataflowTestID))[#"@odata.context"], "#")),

        Fact("GetDataflowDataSourcesInGroup Should Be a Function", true, Value.Is(GetDataflowTransactionsInGroup, Function.Type)),
        Fact("GetDataflowTransactionsInGroup Should Return Correct Metadata", "transactions", Text.AfterDelimiter(Json.Document(GetDataflowTransactionsInGroup(GroupTestID, DataflowTestID))[#"@odata.context"], "#")),

        Fact("GetDataflowsInGroup Should Be a Function", true, Value.Is(GetDataflowsInGroup, Function.Type)),
        Fact("GetDataflowsInGroup Should Be Correct Metadata", "dataflows", Text.AfterDelimiter(Json.Document(GetDataflowsInGroup(GroupTestID))[#"@odata.context"], "#")),

        Fact("GetUpstreamDataflowsInGroup Should Be a Function", true, Value.Is(GetUpstreamDataflowsInGroup, Function.Type)),
        Fact("GetUpstreamDataflowsInGroup Should Be Correct Metadata", "upstreamDataflows", Text.AfterDelimiter(Json.Document(GetUpstreamDataflowsInGroup(GroupTestID, DownstreamDataflowTestID))[#"@odata.context"], "#"))
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
