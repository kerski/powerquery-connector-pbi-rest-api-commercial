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
        Fact("ExecuteQueryInGroup Should Return Results Collection For EVALUATE DateDim", true, Record.HasFields(Json.Document(ExecuteQueryInGroup(GroupTestID, DatasetTestID, "EVALUATE DateDim")), {"results"})),
        Fact("ExecuteQueryInGroup Should Return At Least One Row For EVALUATE DateDim", true, List.Count(Json.Document(ExecuteQueryInGroup(GroupTestID, DatasetTestID, "EVALUATE DateDim"))[results]{0}[tables]{0}[rows]) > 0),
        Fact("ExecuteDaxQueries Should Be a Function", true, Value.Is(ExecuteDaxQueries, Function.Type)),
        Fact("ExecuteDaxQueriesInGroup Should Be a Function", true, Value.Is(ExecuteDaxQueriesInGroup, Function.Type))
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
