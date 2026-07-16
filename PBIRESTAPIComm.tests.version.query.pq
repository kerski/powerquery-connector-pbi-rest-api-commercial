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
    Version = PBIRESTAPIComm.Version,

    facts =
    {
        Fact("PBIRESTAPIComm.Version Should Be Exposed As Text", true, Value.Is(Version, type text)),
        Fact("PBIRESTAPIComm.Version Should Equal 2.1.1", "2.1.1", Version)
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
