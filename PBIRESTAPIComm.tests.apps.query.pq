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

    AppTestID = Environment.FeatureSwitch("AppTestID"),
    AppDashboardTestID = Environment.FeatureSwitch("AppDashboardTestID"),
    AppDashboardTileTestID = Environment.FeatureSwitch("AppDashboardTileTestID"),
    AppReportTestID = Environment.FeatureSwitch("AppReportTestID"),

    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,

    GetApp = _GetFunction("GetApp"),
    GetApps = _GetFunction("GetApps"),
    GetDashboardInApp = _GetFunction("GetDashboardInApp"),
    GetDashboardsInApp = _GetFunction("GetDashboardsInApp"),
    GetReportInApp = _GetFunction("GetReportInApp"),
    GetReportsInApp = _GetFunction("GetReportsInApp"),
    GetDashboardTileInApp = _GetFunction("GetDashboardTileInApp"),
    GetDashboardTilesInApp = _GetFunction("GetDashboardTilesInApp"),

    facts =
    {
        Fact("GetApps Should Be a Function", true, Value.Is(GetApps, Function.Type)),
        Fact("GetApps Should Return Correct Metadata", "apps", Text.AfterDelimiter(Json.Document(GetApps())[#"@odata.context"], "#")),
        Fact("GetApps Should Return More Than One Record", true, List.Count(Json.Document(GetApps())[value]) > 0),

        Fact("GetDashboardInApp Should Be a Function", true, Value.Is(GetDashboardInApp, Function.Type)),
        Fact("GetDashboardInApp Should Return Correct Metadata", "dashboards/$entity", Text.AfterDelimiter(Json.Document(GetDashboardInApp(AppTestID, AppDashboardTestID))[#"@odata.context"], "#")),

        Fact("GetDashboardsInApp Should Be a Function", true, Value.Is(GetDashboardsInApp, Function.Type)),
        Fact("GetDashboardsInApp Should Return Correct Metadata", "dashboards", Text.AfterDelimiter(Json.Document(GetDashboardsInApp(AppTestID))[#"@odata.context"], "#")),

        Fact("GetReportInApp Should Be a Function", true, Value.Is(GetReportInApp, Function.Type)),
        Fact("GetReportInApp Should Return Correct Metadata", "reports/$entity", Text.AfterDelimiter(Json.Document(GetReportInApp(AppTestID, AppReportTestID))[#"@odata.context"], "#")),

        Fact("GetReportsInApp Should Be a Function", true, Value.Is(GetReportsInApp, Function.Type)),
        Fact("GetReportsInApp Should Return Correct Metadata", "reports", Text.AfterDelimiter(Json.Document(GetReportsInApp(AppTestID))[#"@odata.context"], "#")),

        Fact("GetDashboardTileInApp Should Be a Function", true, Value.Is(GetDashboardTileInApp, Function.Type)),
        Fact("GetDashboardTileInGApp Should Return Correct Metadata", "tiles/$entity", Text.AfterDelimiter(Json.Document(GetDashboardTileInApp(AppTestID, AppDashboardTestID, AppDashboardTileTestID))[#"@odata.context"], "#")),

        Fact("GetDashboardTilesInApp Should Be a Function", true, Value.Is(GetDashboardTilesInApp, Function.Type)),
        Fact("GetDashboardTilesInApp Should Return Correct Metadata", "tiles", Text.AfterDelimiter(Json.Document(GetDashboardTilesInApp(AppTestID, AppDashboardTestID))[#"@odata.context"], "#"))
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
