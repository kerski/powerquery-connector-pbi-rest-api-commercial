section UnitTestingUnitTests;

Fact = (_subject as text, _expected, _actual) as record =>
    let
        expected = if Value.Is(_expected, Function.Type) then try _expected() else try _expected,
        actual = if Value.Is(_actual, Function.Type) then try _actual() else try _actual,
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
    DatasetTestID = Environment.FeatureSwitch("DatasetTestID"),
    EnhancedRefreshTestID = Environment.FeatureSwitch("EnhancedRefreshTestID"),

    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,

    GetDatasetDiscoverGatewaysInGroup = _GetFunction("GetDatasetDiscoverGatewaysInGroup"),
    GetDatasetInGroup = _GetFunction("GetDatasetInGroup"),
    GetDatasetToDataflowsLinksInGroup = _GetFunction("GetDatasetToDataflowsLinksInGroup"),
    GetDatasetUsersInGroup = _GetFunction("GetDatasetUsersInGroup"),
    GetDatasetsInGroup = _GetFunction("GetDatasetsInGroup"),
    GetDatasetDatasourcesInGroup = _GetFunction("GetDatasetDatasourcesInGroup"),
    GetDatasetDirectQueryRefreshScheduleInGroup = _GetFunction("GetDatasetDirectQueryRefreshScheduleInGroup"),
    GetDatasetQueryScaleOutStatusInGroup = _GetFunction("GetDatasetQueryScaleOutStatusInGroup"),
    GetDatasetParametersInGroup = _GetFunction("GetDatasetParametersInGroup"),
    GetDatasetRefreshExecutionDetailsInGroup = _GetFunction("GetDatasetRefreshExecutionDetailsInGroup"),
    GetDatasetRefreshHistoryInGroup = _GetFunction("GetDatasetRefreshHistoryInGroup"),
    GetDatasetRefreshScheduleInGroup = _GetFunction("GetDatasetRefreshScheduleInGroup"),
    ExecuteQuery = _GetFunction("ExecuteQuery"),
    ExecuteQueryInGroup = _GetFunction("ExecuteQueryInGroup"),
    ExecuteDaxQueries = _GetFunction("ExecuteDaxQueries"),
    ExecuteDaxQueriesInGroup = _GetFunction("ExecuteDaxQueriesInGroup"),

    TopNDateDimQuery = "EVALUATE TOPN(10,DateDim,DateDim[Date],DESC)",
    TopN1DateDimQuery = "EVALUATE TOPN(1,DateDim,DateDim[Date],DESC)",
    TopN11DateDimQuery = "EVALUATE TOPN(11,DateDim,DateDim[Date],DESC)",
    GetExecuteQueryTopNJson = () => Json.Document(ExecuteQueryInGroup(GroupTestID, DatasetTestID, TopNDateDimQuery)),
    GetExecuteQueryTopNRows = () => GetExecuteQueryTopNJson()[results]{0}[tables]{0}[rows],
    GetExecuteDaxTopN1Rows = () => Table.ToRows(ExecuteDaxQueriesInGroup(GroupTestID, DatasetTestID, TopN1DateDimQuery)),
    GetExecuteDaxTopNRows = () => Table.ToRows(ExecuteDaxQueriesInGroup(GroupTestID, DatasetTestID, TopNDateDimQuery)),
    GetExecuteDaxTopN11Rows = () => Table.ToRows(ExecuteDaxQueriesInGroup(GroupTestID, DatasetTestID, TopN11DateDimQuery)),
    ExpectedTopNRows = {
        {"973", "2020-10-01T00:00:00", "Oct-2020", "202010", "Oct-20"},
        {"975", "2020-12-01T00:00:00", "Dec-2020", "202012", "Dec-20"},
        {"974", "2020-11-01T00:00:00", "Nov-2020", "202011", "Nov-20"},
        {"979", "2021-04-01T00:00:00", "Apr-2021", "202104", "Apr-21"},
        {"976", "2021-01-01T00:00:00", "Jan-2021", "202101", "Jan-21"},
        {"977", "2021-02-01T00:00:00", "Feb-2021", "202102", "Feb-21"},
        {"978", "2021-03-01T00:00:00", "Mar-2021", "202103", "Mar-21"},
        {"981", "2021-06-01T00:00:00", "Jun-2021", "202106", "Jun-21"},
        {"982", "2021-07-01T00:00:00", "Jul-2021", "202107", "Jul-21"},
        {"980", "2021-05-01T00:00:00", "May-2021", "202105", "May-21"}
    },
    ExpectedTopNRowsDax = {
        {973, #datetime(2020, 10, 1, 0, 0, 0), "Oct-2020", 202010, "Oct-20"},
        {975, #datetime(2020, 12, 1, 0, 0, 0), "Dec-2020", 202012, "Dec-20"},
        {974, #datetime(2020, 11, 1, 0, 0, 0), "Nov-2020", 202011, "Nov-20"},
        {979, #datetime(2021, 4, 1, 0, 0, 0), "Apr-2021", 202104, "Apr-21"},
        {976, #datetime(2021, 1, 1, 0, 0, 0), "Jan-2021", 202101, "Jan-21"},
        {977, #datetime(2021, 2, 1, 0, 0, 0), "Feb-2021", 202102, "Feb-21"},
        {978, #datetime(2021, 3, 1, 0, 0, 0), "Mar-2021", 202103, "Mar-21"},
        {981, #datetime(2021, 6, 1, 0, 0, 0), "Jun-2021", 202106, "Jun-21"},
        {982, #datetime(2021, 7, 1, 0, 0, 0), "Jul-2021", 202107, "Jul-21"},
        {980, #datetime(2021, 5, 1, 0, 0, 0), "May-2021", 202105, "May-21"}
    },

    facts =
    {
        Fact("GetDatasetDiscoverGatewaysInGroup Should Be a Function", true, Value.Is(GetDatasetDiscoverGatewaysInGroup, Function.Type)),
        Fact("GetDatasetDiscoverGatewaysInGroup Should Be Correct Metadata", "gateways", Text.AfterDelimiter(Json.Document(GetDatasetDiscoverGatewaysInGroup(GroupTestID, DatasetTestID))[#"@odata.context"], "#")),

        Fact("GetDatasetInGroup Should Be a Function", true, Value.Is(GetDatasetInGroup, Function.Type)),
        Fact("GetDatasetInGroup Should Be Correct Metadata", "datasets/$entity", Text.AfterDelimiter(Json.Document(GetDatasetInGroup(GroupTestID, DatasetTestID))[#"@odata.context"], "#")),

        Fact("GetDatasetToDataflowsLinksInGroup Should Be a Function", true, Value.Is(GetDatasetToDataflowsLinksInGroup, Function.Type)),
        Fact("GetDatasetToDataflowsLinksInGroup Should Be Correct Metadata", "Collection(Microsoft.PowerBI.ServiceContracts.Api.DatasetToDataflowLinkResponse)", Text.AfterDelimiter(Json.Document(GetDatasetToDataflowsLinksInGroup(GroupTestID))[#"@odata.context"], "#")),

        Fact("GetDatasetUsersInGroup Should Be a Function", true, Value.Is(GetDatasetUsersInGroup, Function.Type)),
        Fact("GetDatasetUsersInGroup Should Be Correct Metadata", "Collection(Microsoft.PowerBI.ServiceContracts.Api.Access.DatasetUser)", Text.AfterDelimiter(Json.Document(GetDatasetUsersInGroup(GroupTestID, DatasetTestID))[#"@odata.context"], "#")),
        Fact("GetDatasetUsersInGroup Should at least 1 user", true, List.Count(Json.Document(GetDatasetUsersInGroup(GroupTestID, DatasetTestID))[value]) > 0),

        Fact("GetDatasetsInGroup Should Be a Function", true, Value.Is(GetDatasetsInGroup, Function.Type)),
        Fact("GetDatasetsInGroup Should Be Correct Metadata", "datasets", Text.AfterDelimiter(Json.Document(GetDatasetsInGroup(GroupTestID))[#"@odata.context"], "#")),

        Fact("GetDatasetDatasourcesInGroup Should Be a Function", true, Value.Is(GetDatasetDatasourcesInGroup, Function.Type)),
        Fact("GetDatasetDatasourcesInGroup Should Be Correct Metadata", "datasources", Text.AfterDelimiter(Json.Document(GetDatasetDatasourcesInGroup(GroupTestID, DatasetTestID))[#"@odata.context"], "#")),

        Fact("GetDatasetDirectQueryRefreshScheduleInGroup Should Be a Function", true, Value.Is(GetDatasetDirectQueryRefreshScheduleInGroup, Function.Type)),

        Fact("GetDatasetParametersInGroup Should Be a Function", true, Value.Is(GetDatasetParametersInGroup, Function.Type)),
        Fact("GetDatasetParametersInGroup Should Be Correct Metadata", "parameters", Text.AfterDelimiter(Json.Document(GetDatasetParametersInGroup(GroupTestID, DatasetTestID))[#"@odata.context"], "#")),

        Fact("GetDatasetRefreshExecutionDetailsInGroup Should Be a Function", true, Value.Is(GetDatasetRefreshExecutionDetailsInGroup, Function.Type)),
        Fact("GetDatasetRefreshExecutionDetailsInGroup Should Have One Object Return with Completed Status", "Completed", Json.Document(GetDatasetRefreshExecutionDetailsInGroup(GroupTestID, DatasetTestID, EnhancedRefreshTestID))[extendedStatus]),

        Fact("GetDatasetRefreshHistoryInGroup Should Be a Function", true, Value.Is(GetDatasetRefreshHistoryInGroup, Function.Type)),
        Fact("GetDatasetRefreshHistoryInGroup Should Be Correct Metadata", "refreshes", Text.AfterDelimiter(Json.Document(GetDatasetRefreshHistoryInGroup(GroupTestID, DatasetTestID))[#"@odata.context"], "#")),

        Fact("GetDatasetRefreshScheduleInGroup Should Be a Function", true, Value.Is(GetDatasetRefreshScheduleInGroup, Function.Type)),
        Fact("GetDatasetRefreshScheduleInGroup Should Be Correct Metadata", "Microsoft.PowerBI.ServiceContracts.Api.V1.RefreshSchedule", Text.AfterDelimiter(Json.Document(GetDatasetRefreshScheduleInGroup(GroupTestID, DatasetTestID))[#"@odata.context"], "#")),

        Fact("ExecuteQuery Should Be a Function", true, Value.Is(ExecuteQuery, Function.Type)),
        Fact("ExecuteQueryInGroup Should Be a Function", true, Value.Is(ExecuteQueryInGroup, Function.Type)),
        Fact(
            "ExecuteQueryInGroup Should Return Results Collection For TOPN DateDim",
            true,
            () => Record.HasFields(GetExecuteQueryTopNJson(), {"results"})
        ),
        Fact(
            "ExecuteQueryInGroup Should Return 10 Rows For TOPN DateDim",
            10,
            () => List.Count(GetExecuteQueryTopNRows())
        ),
        Fact(
            "ExecuteQueryInGroup Should Match Expected TOPN DateDim Rows",
            ExpectedTopNRows,
            () =>
                List.Transform(
                    GetExecuteQueryTopNRows(),
                    each List.Transform(Record.FieldValues(_), each Text.From(_))
                )
        ),
        Fact("ExecuteDaxQueries Should Be a Function", true, Value.Is(ExecuteDaxQueries, Function.Type)),
        Fact("ExecuteDaxQueriesInGroup Should Be a Function", true, Value.Is(ExecuteDaxQueriesInGroup, Function.Type)),
        Fact(
            "ExecuteDaxQueriesInGroup Should Return 10 Rows For TOPN DateDim",
            10,
            () => List.Count(GetExecuteDaxTopNRows())
        ),
        Fact(
            "ExecuteDaxQueriesInGroup Should Return 1 Row For TOPN1 DateDim",
            1,
            () => List.Count(GetExecuteDaxTopN1Rows())
        ),
        Fact(
            "ExecuteDaxQueriesInGroup TOPN1 First DateID Should Be 973",
            973,
            () => GetExecuteDaxTopN1Rows(){0}{0}
        ),
        Fact(
            "ExecuteDaxQueriesInGroup Should Return 11 Rows For TOPN11 DateDim",
            11,
            () => List.Count(GetExecuteDaxTopN11Rows())
        ),
        Fact(
            "ExecuteDaxQueriesInGroup TOPN11 First DateID Should Be 973",
            973,
            () => GetExecuteDaxTopN11Rows(){0}{0}
        ),
        Fact(
            "ExecuteDaxQueriesInGroup Should Match Expected TOPN DateDim Rows",
            ExpectedTopNRowsDax,
            () => GetExecuteDaxTopNRows()
        )
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
