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

    PipelineTestID = Environment.FeatureSwitch("PipelineTestID"),

    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,

    GetPipeline = _GetFunction("GetPipeline"),
    GetPipelineOperation = _GetFunction("GetPipelineOperation"),
    GetPipelineOperations = _GetFunction("GetPipelineOperations"),
    GetPipelineStageArtifacts = _GetFunction("GetPipelineStageArtifacts"),
    GetPipelineStages = _GetFunction("GetPipelineStages"),
    GetPipelineUsers = _GetFunction("GetPipelineUsers"),
    GetPipelines = _GetFunction("GetPipelines"),

    facts =
    {
        Fact("GetPipeline Should Be a Function", true, Value.Is(GetPipeline, Function.Type)),
        Fact("GetPipeline Should Be Correct Metadata", "pipelines/$entity", Text.AfterDelimiter(Json.Document(GetPipeline(PipelineTestID))[#"@odata.context"], "#")),

        Fact("GetPipelineOperation Should Be a Function", true, Value.Is(GetPipelineOperation, Function.Type)),

        Fact("GetPipelineOperations Should Be a Function", true, Value.Is(GetPipelineOperations, Function.Type)),
        Fact("GetPipelineOperations Should Be Correct Metadata", "operations", Text.AfterDelimiter(Json.Document(GetPipelineOperations(PipelineTestID))[#"@odata.context"], "#")),

        Fact("GetPipelineStageArtifacts Should Be a Function", true, Value.Is(GetPipelineStageArtifacts, Function.Type)),
        Fact("GetPipelineStageArtifacts Should Be Correct Metadata", "Microsoft.PowerBI.ServiceContracts.Api.PipelineStageArtifacts", Text.AfterDelimiter(Json.Document(GetPipelineStageArtifacts(PipelineTestID, 0))[#"@odata.context"], "#")),
        Fact("GetPipelineStageArtifacts Should Error if Stage Order Not 0, 1, or 2", true, Value.Is(GetPipelineStageArtifacts(PipelineTestID, 3), Table.Type)),

        Fact("GetPipelineStages Should Be a Function", true, Value.Is(GetPipelineStages, Function.Type)),
        Fact("GetPipelineStages Should Be Correct Metadata", "Collection(Microsoft.PowerBI.ServiceContracts.Api.PipelineStage)", Text.AfterDelimiter(Json.Document(GetPipelineStages(PipelineTestID))[#"@odata.context"], "#")),

        Fact("GetPipelineUsers Should Be a Function", true, Value.Is(GetPipelineUsers, Function.Type)),
        Fact("GetPipelineUsers Should Be Correct Metadata", "Collection(Microsoft.PowerBI.ServiceContracts.Api.PipelineAccessRightEntry)", Text.AfterDelimiter(Json.Document(GetPipelineUsers(PipelineTestID))[#"@odata.context"], "#")),
        Fact("GetPipelineUsers Should Have At Least 1 User", true, List.Count(Json.Document(GetPipelineUsers(PipelineTestID))[value]) > 0),

        Fact("GetPipelines Should Be a Function", true, Value.Is(GetPipelines, Function.Type)),
        Fact("GetPipelines Should Be Correct Metadata", "pipelines", Text.AfterDelimiter(Json.Document(GetPipelines())[#"@odata.context"], "#"))
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
