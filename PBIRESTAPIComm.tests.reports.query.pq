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
    ReportTestID = Environment.FeatureSwitch("ReportTestID"),
    ReportTestName = Environment.FeatureSwitch("ReportTestName"),
    ExportWorkspaceID = Environment.FeatureSwitch("ExportWorkspaceID"),
    ExportReportID = Environment.FeatureSwitch("ExportReportID"),
    ExportPaginatedReportID = Environment.FeatureSwitch("ExportPaginatedReportID"),

    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,

    GetPaginatedReportDatasourcesInGroup = _GetFunction("GetPaginatedReportDatasourcesInGroup"),
    GetReportPageInGroup = _GetFunction("GetReportPageInGroup"),
    GetReportPagesInGroup = _GetFunction("GetReportPagesInGroup"),
    GetReportInGroup = _GetFunction("GetReportInGroup"),
    GetReportsInGroup = _GetFunction("GetReportsInGroup"),
    ExportReportInGroup = _GetFunction("ExportReportInGroup"),

    facts =
    {
        Fact("GetPaginatedReportDatasourcesInGroup Should Be a Function", true, Value.Is(GetPaginatedReportDatasourcesInGroup, Function.Type)),

        Fact("GetReportPageInGroup Should Be a Function", true, Value.Is(GetReportPageInGroup, Function.Type)),
        Fact("GetReportPageInGroup Should Be Correct Metadata", "pages/$entity", Text.AfterDelimiter(Json.Document(GetReportPageInGroup(GroupTestID, ReportTestID, "ReportSection"))[#"@odata.context"], "#")),

        Fact("GetReportPagesInGroup Should Be a Function", true, Value.Is(GetReportPagesInGroup, Function.Type)),
        Fact("GetReportPagesInGroup Should Be Correct Metadata", "pages", Text.AfterDelimiter(Json.Document(GetReportPagesInGroup(GroupTestID, ReportTestID))[#"@odata.context"], "#")),
        Fact("GetReportPagesInGroup Should Have 2 Pages", 2, List.Count(Json.Document(GetReportPagesInGroup(GroupTestID, ReportTestID))[value])),

        Fact("GetReportInGroup Should Be a Function", true, Value.Is(GetReportInGroup, Function.Type)),
        Fact("GetReportInGroup Should Be Correct Metadata", "reports/$entity", Text.AfterDelimiter(Json.Document(GetReportInGroup(GroupTestID, ReportTestID))[#"@odata.context"], "#")),
        Fact("GetReportInGroup Should Have More Than 0 Reports", ReportTestName, Json.Document(GetReportInGroup(GroupTestID, ReportTestID))[name]),

        Fact("GetReportsInGroup Should Be a Function", true, Value.Is(GetReportsInGroup, Function.Type)),
        Fact("GetReportsInGroup Should Be Correct Metadata", "reports", Text.AfterDelimiter(Json.Document(GetReportsInGroup(GroupTestID))[#"@odata.context"], "#")),
        Fact("GetReportsInGroup Should Have More Than 0 Reports", true, List.Count(Json.Document(GetReportsInGroup(GroupTestID))[value]) > 0),

        Fact("ExportReportInGroup Should Be a Function", true, Value.Is(ExportReportInGroup, Function.Type)),
        Fact("ExportReportInGroup Should Return Binary When LiveConnect", true, Value.Is(ExportReportInGroup(ExportWorkspaceID, ExportReportID, "LiveConnect", false), Binary.Type)),
        Fact("ExportReportInGroup Should Return When IncludeModel", true, Value.Is(ExportReportInGroup(ExportWorkspaceID, ExportReportID, "IncludeModel", false), Binary.Type)),
        Fact("ExportReportInGroup Should Return When IncludeModel (Paginated Report)", true, Value.Is(ExportReportInGroup(ExportWorkspaceID, ExportPaginatedReportID, "IncludeModel", false), Binary.Type))
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
