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
    ExecuteDaxJsonToTable = PBIRESTAPIComm.ExecuteDaxJsonToTable,
    ExecuteDaxParseArrowResponse = PBIRESTAPIComm.ExecuteDaxParseArrowResponse,
    ExecuteDaxParseJsonResponse = PBIRESTAPIComm.ExecuteDaxParseJsonResponse,
    ExecuteDaxDetectResponseKind = PBIRESTAPIComm.ExecuteDaxDetectResponseKind,
    ExecuteDaxResponseAsTable = PBIRESTAPIComm.ExecuteDaxResponseAsTable,

    GetError = (operation as function) as nullable record =>
        let
            attempt = try operation()
        in
            if attempt[HasError] then attempt[Error] else null,

    OperationHasError = (operation as function) as logical =>
        let
            attempt = try operation()
        in
            attempt[HasError],

    ErrorDetailFieldEquals = (operation as function, fieldName as text, expectedValue as any) as logical =>
        let
            err = GetError(operation),
            detail = if err = null then null else (try err[Detail] otherwise null),
            hasField = detail <> null and Record.HasFields(detail, fieldName),
            actualValue = if hasField then Record.Field(detail, fieldName) else null
        in
            hasField and actualValue = expectedValue,

    ErrorMessageContains = (operation as function, expectedText as text) as logical =>
        let
            err = GetError(operation),
            msg = if err = null then "" else (try Text.From(err[Message]) otherwise "")
        in
            Text.Contains(msg, expectedText),

    JsonHeaders = [#"Content-Type" = "application/json"],
    ArrowHeaders = [#"Content-Type" = "application/vnd.apache.arrow.stream"],

    NonArrowJsonPayload = Json.FromValue(
        [
            results = {
                [
                    tables = {
                        [
                            columns = {[name = "A"], [name = "B"]},
                            rows = {[A = 1, B = "x"], [A = 2, B = "y"]}
                        ]
                    }
                ]
            }
        ]
    ),

    MalformedArrowPayload = Binary.Combine({Binary.FromText("4152524f5731", BinaryEncoding.Hex), Text.ToBinary("broken")}),

    facts =
    {
        Fact("ExecuteDaxJsonToTable Test Hook Should Be a Function", true, Value.Is(ExecuteDaxJsonToTable, Function.Type)),
        Fact("ExecuteDaxParseArrowResponse Test Hook Should Be a Function", true, Value.Is(ExecuteDaxParseArrowResponse, Function.Type)),
        Fact("ExecuteDaxParseJsonResponse Test Hook Should Be a Function", true, Value.Is(ExecuteDaxParseJsonResponse, Function.Type)),
        Fact("ExecuteDaxDetectResponseKind Test Hook Should Be a Function", true, Value.Is(ExecuteDaxDetectResponseKind, Function.Type)),
        Fact("ExecuteDaxResponseAsTable Test Hook Should Be a Function", true, Value.Is(ExecuteDaxResponseAsTable, Function.Type)),

        Fact(
            "NoFallback Contract DetectResponseKind Should Route NonArrow JSON To Json Path",
            "Json",
            () => ExecuteDaxDetectResponseKind(NonArrowJsonPayload, JsonHeaders)
        ),
        Fact(
            "NoFallback Contract DetectResponseKind Should Route Arrow Header To Arrow Path",
            "Arrow",
            () => ExecuteDaxDetectResponseKind(NonArrowJsonPayload, ArrowHeaders)
        ),
        Fact(
            "NoFallback Contract Json Parser Helper Should Materialize Table",
            true,
            () => Value.Is(ExecuteDaxParseJsonResponse(NonArrowJsonPayload), type table)
        ),

        Fact(
            "NoFallback Contract NonArrow JSON Should Materialize As Table",
            true,
            () => Value.Is(ExecuteDaxResponseAsTable(NonArrowJsonPayload, JsonHeaders), type table)
        ),
        Fact(
            "NoFallback Contract NonArrow JSON Should Preserve Row Count",
            2,
            () => Table.RowCount(ExecuteDaxResponseAsTable(NonArrowJsonPayload, JsonHeaders))
        ),
        Fact(
            "NoFallback Contract NonArrow JSON Should Preserve Ordered Column Names",
            {"A", "B"},
            () => Table.ColumnNames(ExecuteDaxResponseAsTable(NonArrowJsonPayload, JsonHeaders))
        ),

        Fact(
            "NoFallback Contract Arrow Header With JSON Payload Should Surface Failure",
            true,
            () => OperationHasError(() => ExecuteDaxResponseAsTable(NonArrowJsonPayload, ArrowHeaders))
        ),
        Fact(
            "NoFallback Contract Arrow Parser Helper Should Surface Failure For JSON Payload",
            true,
            () => OperationHasError(() => ExecuteDaxParseArrowResponse(NonArrowJsonPayload))
        ),
        Fact(
            "NoFallback Contract Arrow Header With JSON Payload Should Report Arrow Module",
            true,
            () => ErrorDetailFieldEquals(() => ExecuteDaxResponseAsTable(NonArrowJsonPayload, ArrowHeaders), "Module", "Arrow.Stream")
        ),
        Fact(
            "NoFallback Contract Arrow Header With JSON Payload Should Report Parse Stage",
            true,
            () => ErrorDetailFieldEquals(() => ExecuteDaxResponseAsTable(NonArrowJsonPayload, ArrowHeaders), "Stage", "Parse")
        ),

        Fact(
            "NoFallback Contract Malformed Arrow Payload Should Surface Actionable Error",
            true,
            () => ErrorMessageContains(() => ExecuteDaxResponseAsTable(MalformedArrowPayload, JsonHeaders), "Arrow parse failed")
        ),
        Fact(
            "NoFallback Contract Malformed Arrow Payload Should Report Stream Module",
            true,
            () => ErrorDetailFieldEquals(() => ExecuteDaxResponseAsTable(MalformedArrowPayload, JsonHeaders), "Module", "Arrow.Stream")
        ),
        Fact(
            "NoFallback Contract Malformed Arrow Payload Should Report Parse Stage",
            true,
            () => ErrorDetailFieldEquals(() => ExecuteDaxResponseAsTable(MalformedArrowPayload, JsonHeaders), "Stage", "Parse")
        )
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
