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
    GroupNameFilter = Environment.FeatureSwitch("GroupNameFilter"),

    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,

    GetGroupUsers = _GetFunction("GetGroupUsers"),
    GetGroups = _GetFunction("GetGroups"),

    facts =
    {
        Fact("GetGroupUsers Should Be a Function", true, Value.Is(GetGroupUsers, Function.Type)),
        Fact("GetGroupUsers Should Be Correct Metadata", "users", Text.AfterDelimiter(Json.Document(GetGroupUsers(GroupTestID))[#"@odata.context"], "#")),
        Fact("GetGroupUsers Should Have More Than 0 Users", true, List.Count(Json.Document(GetGroupUsers(GroupTestID))[value]) > 0),

        Fact("GetGroups Should Be a Function", true, Value.Is(GetGroups, Function.Type)),
        Fact("GetGroups Should Be Correct Metadata", "groups", Text.AfterDelimiter(Json.Document(GetGroups())[#"@odata.context"], "#")),
        Fact("GetGroups with filter should return the right workspace", GroupTestID, Json.Document(GetGroups(GroupNameFilter))[value]{0}[id])
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
