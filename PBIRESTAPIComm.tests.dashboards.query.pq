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
    DashboardTestID = Environment.FeatureSwitch("DashboardTestID"),
    DashboardTileTestID = Environment.FeatureSwitch("DashboardTileTestID"),

    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,

    GetDashboardInGroup = _GetFunction("GetDashboardInGroup"),
    GetDashboardsInGroup = _GetFunction("GetDashboardsInGroup"),
    GetDashboardTileInGroup = _GetFunction("GetDashboardTileInGroup"),
    GetDashboardTilesInGroup = _GetFunction("GetDashboardTilesInGroup"),

    facts =
    {
        Fact("GetDashboardInGroup Should Be a Function", true, Value.Is(GetDashboardInGroup, Function.Type)),
        Fact("GetDashboardInGroup Should Return Correct Metadata", "dashboards/$entity", Text.AfterDelimiter(Json.Document(GetDashboardInGroup(GroupTestID, DashboardTestID))[#"@odata.context"], "#")),

        Fact("GetDashboardsInGroup Should Be a Function", true, Value.Is(GetDashboardsInGroup, Function.Type)),
        Fact("GetDashboardsInGroup Should Return Correct Metadata", "dashboards", Text.AfterDelimiter(Json.Document(GetDashboardsInGroup(GroupTestID))[#"@odata.context"], "#")),

        Fact("GetDashboardTileInGroup Should Be a Function", true, Value.Is(GetDashboardTileInGroup, Function.Type)),
        Fact("GetDashboardTileInGroup Should Return Correct Metadata", "tiles/$entity", Text.AfterDelimiter(Json.Document(GetDashboardTileInGroup(GroupTestID, DashboardTestID, DashboardTileTestID))[#"@odata.context"], "#")),

        Fact("GetDashboardTilesInGroup Should Be a Function", true, Value.Is(GetDashboardTilesInGroup, Function.Type)),
        Fact("GetDashboardTilesInGroup Should Return Correct Metadata", "tiles", Text.AfterDelimiter(Json.Document(GetDashboardTilesInGroup(GroupTestID, DashboardTestID))[#"@odata.context"], "#"))
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
