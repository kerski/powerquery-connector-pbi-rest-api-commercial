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
    ScorecardOneTestID = Environment.FeatureSwitch("ScorecardOneTestID"),
    ScorecardOneGoalTestID = Environment.FeatureSwitch("ScorecardOneGoalTestID"),
    ScorecardOneGoalWithRefreshTestID = Environment.FeatureSwitch("ScorecardOneGoalWithRefreshTestID"),
    ScorecardInternalReportId = Environment.FeatureSwitch("ScorecardInternalReportId"),
    ScorecardOneGoalTimestampID = Expression.Evaluate(Environment.FeatureSwitch("ScorecardOneGoalTimestampID")),

    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,

    GetScorecardGoalValuesInGroup = _GetFunction("GetScorecardGoalValuesInGroup"),
    GetScorecardGoalValueInGroup = _GetFunction("GetScorecardGoalValueInGroup"),
    GetScorecardGoalsInGroup = _GetFunction("GetScorecardGoalsInGroup"),
    GetScorecardGoalInGroup = _GetFunction("GetScorecardGoalInGroup"),
    GetScorecardGoalRefreshHistoryInGroup = _GetFunction("GetScorecardGoalRefreshHistoryInGroup"),
    GetScorecardGoalsStatusRulesInGroup = _GetFunction("GetScorecardGoalsStatusRulesInGroup"),
    GetScorecardsInGroup = _GetFunction("GetScorecardsInGroup"),
    GetScorecardInGroup = _GetFunction("GetScorecardInGroup"),
    GetScorecardByReportIdInGroup = _GetFunction("GetScorecardByReportIdInGroup"),

    facts =
    {
        Fact("GetScorecardGoalValuesInGroup Should Be a Function", true, Value.Is(GetScorecardGoalValuesInGroup, Function.Type)),
        Fact("GetScorecardGoalValuesInGroup Should Be Correct Metadata", true, Text.EndsWith(Text.AfterDelimiter(Json.Document(GetScorecardGoalValuesInGroup(GroupTestID, ScorecardOneTestID, ScorecardOneGoalTestID))[#"@odata.context"], "#"), "/metricValues")),
        Fact("GetScorecardGoalValuesInGroup Should Have Notes", true, Record.Field(List.First(Json.Document(GetScorecardGoalValuesInGroup(GroupTestID, ScorecardOneTestID, ScorecardOneGoalTestID, "notes"))[#"value"]), "notes") <> null),

        Fact("GetScorecardGoalValueInGroup Should Be a Function", true, Value.Is(GetScorecardGoalValueInGroup, Function.Type)),
        Fact("GetScorecardGoalValueInGroup Should Be Correct Metadata", true, Text.EndsWith(Text.AfterDelimiter(Json.Document(GetScorecardGoalValueInGroup(GroupTestID, ScorecardOneTestID, ScorecardOneGoalTestID, ScorecardOneGoalTimestampID))[#"@odata.context"], "#"), "/metricValues/$entity")),
        Fact("GetScorecardGoalValueInGroup Should Contain Notes", true, Json.Document(GetScorecardGoalValueInGroup(GroupTestID, ScorecardOneTestID, ScorecardOneGoalTestID, ScorecardOneGoalTimestampID, "notes"))[#"notes"] <> null),

        Fact("GetScorecardGoalsInGroup Should Be a Function", true, Value.Is(GetScorecardGoalsInGroup, Function.Type)),
        Fact("GetScorecardGoalsInGroup Should Be Correct Metadata", "scorecards(" & ScorecardOneTestID & ")/metrics", Text.AfterDelimiter(Json.Document(GetScorecardGoalsInGroup(GroupTestID, ScorecardOneTestID))[#"@odata.context"], "#")),
        Fact("GetScorecardGoalsInGroup Should Return Goal With Expected Scorecard Id", ScorecardOneTestID, Record.Field(List.First(Json.Document(GetScorecardGoalsInGroup(GroupTestID, ScorecardOneTestID))[#"value"]), "scorecardId")),
        Fact("GetScorecardGoalsInGroup Should Return Goal Values When Expanded", true, Record.HasFields(List.First(Json.Document(GetScorecardGoalsInGroup(GroupTestID, ScorecardOneTestID, "goalValues", null))[#"value"]), "goalValues")),
        Fact("GetScorecardGoalsInGroup Should Return Aggregations When Expanded", true, Record.HasFields(List.First(Json.Document(GetScorecardGoalsInGroup(GroupTestID, ScorecardOneTestID, "goalValues,aggregations", null))[#"value"]), "aggregations")),
        Fact("GetScorecardGoalsInGroup Should Not Return Scorecard Id Field When Only Name And Level Selected.", false, Record.HasFields(List.First(Json.Document(GetScorecardGoalsInGroup(GroupTestID, ScorecardOneTestID, null, "name,level"))[#"value"]), {"scorecardId"})),
        Fact("GetScorecardGoalsInGroup Should Return Name and Level Fields", true, Record.HasFields(List.First(Json.Document(GetScorecardGoalsInGroup(GroupTestID, ScorecardOneTestID, null, "name,level"))[#"value"]), {"name", "level"})),

        Fact("GetScorecardGoalInGroup Should Be a Function", true, Value.Is(GetScorecardGoalInGroup, Function.Type)),
        Fact("GetScorecardGoalInGroup Should Be Correct Metadata", true, Text.EndsWith(Text.AfterDelimiter(Json.Document(GetScorecardGoalInGroup(GroupTestID, ScorecardOneTestID, ScorecardOneGoalTestID))[#"@odata.context"], "#"), "/metrics/$entity")),

        Fact("GetScorecardGoalRefreshHistoryInGroup Should Be a Function", true, Value.Is(GetScorecardGoalRefreshHistoryInGroup, Function.Type)),
        Fact("GetScorecardGoalRefreshHistoryInGroup Should Be Correct Metadata", true, Text.Contains(Text.AfterDelimiter(Json.Document(GetScorecardGoalRefreshHistoryInGroup(GroupTestID, ScorecardOneTestID, ScorecardOneGoalWithRefreshTestID))[#"@odata.context"], "#"), "Collection(Microsoft.PowerBI.ServiceContracts.Api.GoalRefreshHistory")),

        Fact("GetScorecardGoalsStatusRulesInGroup Should Be a Function", true, Value.Is(GetScorecardGoalsStatusRulesInGroup, Function.Type)),
        Fact("GetScorecardGoalsStatusRulesInGroup Should Be Correct Metadata", "scorecards(" & ScorecardOneTestID & ")/metrics(" & ScorecardOneGoalTestID & ")/statusRules", Text.AfterDelimiter(Json.Document(GetScorecardGoalsStatusRulesInGroup(GroupTestID, ScorecardOneTestID, ScorecardOneGoalTestID))[#"@odata.context"], "#")),

        Fact("GetScorecardsInGroup Should Be a Function", true, Value.Is(GetScorecardsInGroup, Function.Type)),
        Fact("GetScorecardsInGroup Should Be Correct Metadata", "scorecards", Text.AfterDelimiter(Json.Document(GetScorecardsInGroup(GroupTestID))[#"@odata.context"], "#")),
        Fact("GetScorecardsInGroup Should Return Two Scorecards", 2, Json.Document(GetScorecardsInGroup(GroupTestID))[#"@odata.count"]),
        Fact("GetScorecardsInGroup Should Return One Scorecards When Top 1 provided", 1, Json.Document(GetScorecardsInGroup(GroupTestID, 1))[#"@odata.count"]),

        Fact("GetScorecardInGroup Should Be a Function", true, Value.Is(GetScorecardInGroup, Function.Type)),
        Fact("GetScorecardInGroup Should Return a goals property", true, List.Count(Json.Document(GetScorecardInGroup(GroupTestID, ScorecardOneTestID, "goals($expand=goalValues)"))[#"goals"]) > 0),
        Fact("GetScorecardInGroup Should Return a goal values property", true, Record.Field(List.First(Json.Document(GetScorecardInGroup(GroupTestID, ScorecardOneTestID, "goals($expand=goalValues)"))[#"goals"]), "goalValues") <> null),

        Fact("GetScorecardByReportIdInGroup Should Be a Function", true, Value.Is(GetScorecardByReportIdInGroup, Function.Type)),
        Fact("GetScorecardByReportIdInGroup Should Be Correct Metadata", "scorecards/$entity", Text.AfterDelimiter(Json.Document(GetScorecardByReportIdInGroup(GroupTestID, ScorecardInternalReportId))[#"@odata.context"], "#")),
        Fact("GetScorecardByReportIdInGroup Should Return a goals property", true, List.Count(Json.Document(GetScorecardByReportIdInGroup(GroupTestID, ScorecardInternalReportId, "goals($expand=goalValues)"))[#"goals"]) > 0),
        Fact("GetScorecardByReportIdInGroup Should Return a goal values property", true, Record.Field(List.First(Json.Document(GetScorecardByReportIdInGroup(GroupTestID, ScorecardInternalReportId, "goals($expand=goalValues)"))[#"goals"]), "goalValues") <> null)
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
