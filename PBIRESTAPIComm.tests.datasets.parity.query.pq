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
    Source = PBIRESTAPIComm.FunctionCatalog(),

    GroupTestID = Environment.FeatureSwitch("GroupTestID"),
    DatasetTestID = Environment.FeatureSwitch("DatasetTestID"),
    RunLiveParity = Text.Lower(Text.From(Environment.FeatureSwitch("RunLiveParity"))) = "true",

    _GetFunction = (_func_key as text) =>
        let
            Result = try Source{[Key = _func_key]}[Data] otherwise "Not a function"
        in
            Result,

    ExecuteQuery = _GetFunction("ExecuteQuery"),
    ExecuteQueryInGroup = _GetFunction("ExecuteQueryInGroup"),
    ExecuteDaxQueries = _GetFunction("ExecuteDaxQueries"),
    ExecuteDaxQueriesInGroup = _GetFunction("ExecuteDaxQueriesInGroup"),

    TopNDateDimQuery = "EVALUATE TOPN(10,DateDim,DateDim[Date],DESC)",
    TopN10DateIdOnlyQuery = "EVALUATE SELECTCOLUMNS(TOPN(10,DateDim,DateDim[Date],DESC), ""DateID"", DateDim[DateID])",
    TopN1DateIdOnlyQuery = "EVALUATE SELECTCOLUMNS(TOPN(1,DateDim,DateDim[Date],DESC), ""DateID"", DateDim[DateID])",
    TopN5TextAndIdQuery = "EVALUATE SELECTCOLUMNS(TOPN(5,DateDim,DateDim[Date],DESC), ""DateID"", DateDim[DateID], ""Month"", DateDim[MonthYear], ""Label"", DateDim[MonthYearShort])",
    TopN3WithBlankQuery = "EVALUATE SELECTCOLUMNS(TOPN(3,DateDim,DateDim[Date],DESC), ""DateID"", DateDim[DateID], ""BlankCol"", BLANK())",
    CoreTypeSingleRowQuery = "EVALUATE ROW(""IntVal"", 42, ""DecVal"", 3.1415926536, ""BoolVal"", TRUE(), ""TextVal"", ""alpha"", ""DateVal"", DATE(2024,1,31), ""DateTimeVal"", DATE(2024,1,31) + TIME(13,14,15), ""BlankVal"", BLANK())",
    CoreTypeMultiRowQuery = "EVALUATE UNION(ROW(""IntVal"", 0, ""DecVal"", 0.5, ""BoolVal"", FALSE(), ""TextVal"", ""zero"", ""DateVal"", DATE(2024,1,1), ""DateTimeVal"", DATE(2024,1,1) + TIME(0,0,0), ""BlankVal"", BLANK()), ROW(""IntVal"", 7, ""DecVal"", 99.125, ""BoolVal"", TRUE(), ""TextVal"", ""seven"", ""DateVal"", DATE(2024,2,2), ""DateTimeVal"", DATE(2024,2,2) + TIME(7,8,9), ""BlankVal"", BLANK()))",
    DateDimBoundedProjectionQuery = "EVALUATE SELECTCOLUMNS(TOPN(1000, DateDim, DateDim[DateID], ASC), ""DateID"", DateDim[DateID], ""Date"", DateDim[Date], ""MonthYear"", DateDim[MonthYear], ""MonthYearKey"", DateDim[MonthYearKey], ""MonthYearShort"", DateDim[MonthYearShort])",
    TopN10MarvelFactQuery = "EVALUATE TOPN(10,MarvelFact)",
    TopN10AlignmentDimQuery = "EVALUATE TOPN(10,AlignmentDim)",
    TopN10EyeDimQuery = "EVALUATE TOPN(10,EyeDim)",
    LargeMultiBatchQuery = "EVALUATE SELECTCOLUMNS(GENERATESERIES(1, 65000, 1), ""N"", [Value], ""N2"", [Value] * 2)",
    UnicodeTextQuery = "EVALUATE UNION(ROW(""T"", ""ASCII""), ROW(""T"", ""café""), ROW(""T"", ""日本語""), ROW(""T"", ""🎉""), ROW(""T"", """"), ROW(""T"", "" trim test  ""))",
    MixedNullBitmapQuery = "EVALUATE UNION(ROW(""V"", 1, ""B"", TRUE(), ""A"", BLANK()), ROW(""V"", BLANK(), ""B"", BLANK(), ""A"", BLANK()), ROW(""V"", 3, ""B"", FALSE(), ""A"", BLANK()), ROW(""V"", BLANK(), ""B"", TRUE(), ""A"", BLANK()), ROW(""V"", 5, ""B"", BLANK(), ""A"", BLANK()), ROW(""V"", BLANK(), ""B"", FALSE(), ""A"", BLANK()), ROW(""V"", 7, ""B"", TRUE(), ""A"", BLANK()), ROW(""V"", BLANK(), ""B"", BLANK(), ""A"", BLANK()), ROW(""V"", 9, ""B"", FALSE(), ""A"", BLANK()), ROW(""V"", 10, ""B"", TRUE(), ""A"", BLANK()))",
    LargeDictionaryEncodedQuery = "EVALUATE CROSSJOIN(SELECTCOLUMNS(GENERATESERIES(1, 5000, 1), ""N"", [Value]), AlignmentDim)",
    ExtendedScalarQuery = "EVALUATE ROW(""TimeVal"", TIME(23,59,59), ""TimeMin"", TIME(0,0,0), ""BigIntPos"", 9999999999, ""BigIntNeg"", -9999999999, ""HighPrecDec"", 0.1234567890123456, ""LargeDec"", 9876543210.123456789, ""SmallDec"", 0.000000000123, ""NegSmallDec"", -0.000000000456, ""IntMax32Plus"", 2147483648, ""IntMin32Minus"", -2147483649)",
    EmptyResultQuery = "EVALUATE FILTER(ROW(""X"", 1), FALSE())",
    SingleRowBoundaryQuery = "EVALUATE ROW(""BoundaryInt"", -2147483648, ""BoundaryText"", ""single-row"", ""BoundaryBlank"", BLANK())",
    WideComputedColumnsQuery = "EVALUATE ROW(""Base"", 5, ""PlusOne"", 5 + 1, ""TimesTwo"", 5 * 2, ""AsText"", FORMAT(5, ""0""), ""QualifiedLabel"", ""DateDim[MonthYear]"", ""Upper"", UPPER(""mixEd""), ""Lower"", LOWER(""mixEd""), ""BoolExpr"", 5 > 2)",

    CanonicalDecimalPlaces = 9,

    CanonicalizeNumber = (value as number) as text =>
        Number.ToText(Number.Round(value, CanonicalDecimalPlaces), "0.################", "en-US"),

    CanonicalizeCell = (value as any) as text =>
        if value = null then "<null>"
        else if Value.Is(value, type number)
            then CanonicalizeNumber(value)
            else if Value.Is(value, type datetimezone)
                then DateTimeZone.ToText(DateTimeZone.SwitchZone(value, 0), "yyyy-MM-ddTHH:mm:ssZ")
                else if Value.Is(value, type datetime)
                    then DateTime.ToText(value, "yyyy-MM-ddTHH:mm:ss")
                    else if Value.Is(value, type date)
                        then Date.ToText(value, "yyyy-MM-dd")
                        else if Value.Is(value, type time)
                            then Time.ToText(value, "HH:mm:ss")
                            else if Value.Is(value, type logical)
                                then if value then "true" else "false"
                                else if Value.Is(value, type binary)
                                    then Binary.ToText(value, BinaryEncoding.Hex)
                                    else Text.From(value),

    CanonicalTypeName = (value as any) as text =>
        if value = null then "null"
        else if Value.Is(value, type number) then "number"
        else if Value.Is(value, type datetimezone) then "datetimezone"
        else if Value.Is(value, type datetime) then "datetime"
        else if Value.Is(value, type date) then "date"
        else if Value.Is(value, type time) then "time"
        else if Value.Is(value, type logical) then "logical"
        else if Value.Is(value, type binary) then "binary"
        else if Value.Is(value, type text) then "text"
        else "unknown",

    ParityError = (message as text, details as record) as none =>
        error Error.Record("Parity", message, details),

    GetExecuteQueryRowsInGroup = (query as text) as list =>
        Json.Document(ExecuteQueryInGroup(GroupTestID, DatasetTestID, query))[results]{0}[tables]{0}[rows],

    GetExecuteQueryRows = (query as text) as list =>
        Json.Document(ExecuteQuery(DatasetTestID, query))[results]{0}[tables]{0}[rows],

    GetExecuteDaxTableInGroup = (query as text) as table =>
        ExecuteDaxQueriesInGroup(GroupTestID, DatasetTestID, query),

    GetExecuteDaxTable = (query as text) as table =>
        ExecuteDaxQueries(DatasetTestID, query),

    GetExecuteQueryColumns = (rows as list) as list =>
        let
            ordered = List.Accumulate(
                rows,
                {},
                (state, row) => List.Distinct(List.Combine({state, Record.FieldNames(row)}))
            )
        in
            ordered,

    CanonicalizeRecord = (row as record, columns as list) as list =>
        List.Transform(
            columns,
            each CanonicalizeCell(if Record.HasFields(row, _) then Record.Field(row, _) else null)
        ),

    GetExecuteQueryCanonicalFromRows = (rows as list) as record =>
        let
            columns = GetExecuteQueryColumns(rows),
            canonicalRows = List.Transform(rows, each CanonicalizeRecord(_, columns))
        in
            [Columns = columns, Rows = canonicalRows, RawRows = rows],

    GetExecuteQueryCanonicalInGroup = (query as text) as record =>
        GetExecuteQueryCanonicalFromRows(GetExecuteQueryRowsInGroup(query)),

    GetExecuteQueryCanonical = (query as text) as record =>
        GetExecuteQueryCanonicalFromRows(GetExecuteQueryRows(query)),

    GetExecuteDaxCanonicalFromTable = (tableResult as table) as record =>
        let
            columns = Table.ColumnNames(tableResult),
            rows = Table.ToRecords(tableResult),
            canonicalRows = List.Transform(rows, each CanonicalizeRecord(_, columns))
        in
            [Columns = columns, Rows = canonicalRows, RawRows = rows],

    GetExecuteDaxCanonicalInGroup = (query as text) as record =>
        GetExecuteDaxCanonicalFromTable(GetExecuteDaxTableInGroup(query)),

    GetExecuteDaxCanonical = (query as text) as record =>
        GetExecuteDaxCanonicalFromTable(GetExecuteDaxTable(query)),

    GetRawValue = (rawRows as list, rowIndex as number, columnName as text) as any =>
        if rowIndex < 0 or rowIndex >= List.Count(rawRows)
            then null
            else
                let
                    row = rawRows{rowIndex}
                in
                    if Record.HasFields(row, columnName) then Record.Field(row, columnName) else null,

    AssertCanonicalParity = (queryIdentifier as text, expected as record, actual as record, optional endpointPair as nullable text) as logical =>
        let
            pair = if endpointPair = null then "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup" else endpointPair,
            expectedColumns = expected[Columns],
            actualColumns = actual[Columns],
            expectedRows = expected[Rows],
            actualRows = actual[Rows],
            expectedRawRows = expected[RawRows],
            actualRawRows = actual[RawRows],
            expectedColumnCount = List.Count(expectedColumns),
            actualColumnCount = List.Count(actualColumns),
            _columnCountCheck =
                if expectedColumnCount <> actualColumnCount
                    then ParityError(
                        "Parity column count mismatch",
                        [
                            QueryIdentifier = queryIdentifier,
                            EndpointPair = pair,
                            Coordinate = [RowIndex = null, ColumnName = null],
                            ExpectedColumnCount = expectedColumnCount,
                            ActualColumnCount = actualColumnCount,
                            ExpectedColumns = Text.Combine(List.Transform(expectedColumns, each Text.From(_)), ","),
                            ActualColumns = Text.Combine(List.Transform(actualColumns, each Text.From(_)), ",")
                        ]
                    )
                    else true,
            _columnNameCheck =
                let
                    columnMatches = List.Transform({0..expectedColumnCount - 1}, each expectedColumns{_} = actualColumns{_}),
                    mismatchIndex = List.PositionOf(columnMatches, false)
                in
                    if mismatchIndex >= 0
                        then ParityError(
                            "Parity column name/order mismatch",
                            [
                                QueryIdentifier = queryIdentifier,
                                EndpointPair = pair,
                                Coordinate = [RowIndex = null, ColumnName = expectedColumns{mismatchIndex}],
                                ExpectedColumn = Text.From(expectedColumns{mismatchIndex}),
                                ActualColumn = Text.From(actualColumns{mismatchIndex})
                            ]
                        )
                        else true,
            expectedRowCount = List.Count(expectedRows),
            actualRowCount = List.Count(actualRows),
            _rowCountCheck =
                if expectedRowCount <> actualRowCount
                    then ParityError(
                        "Parity row count mismatch",
                        [
                            QueryIdentifier = queryIdentifier,
                            EndpointPair = pair,
                            Coordinate = [RowIndex = null, ColumnName = null],
                            ExpectedRowCount = expectedRowCount,
                            ActualRowCount = actualRowCount
                        ]
                    )
                    else true,
            rowIndexes = if expectedRowCount = 0 then {} else {0..expectedRowCount - 1},
            columnIndexes = if expectedColumnCount = 0 then {} else {0..expectedColumnCount - 1},
            mismatch =
                List.First(
                    List.RemoveNulls(
                        List.Transform(
                            rowIndexes,
                            (r) =>
                                List.First(
                                    List.RemoveNulls(
                                        List.Transform(
                                            columnIndexes,
                                            (c) =>
                                                let
                                                    expectedValue = expectedRows{r}{c},
                                                    actualValue = actualRows{r}{c}
                                                in
                                                    if expectedValue = actualValue then null else [RowIndex = r, ColumnIndex = c, ColumnName = expectedColumns{c}, Expected = expectedValue, Actual = actualValue]
                                        )
                                    ),
                                    null
                                )
                        )
                    ),
                    null
                ),
            _valueCheck =
                if mismatch <> null
                    then
                        let
                            expectedRaw = GetRawValue(expectedRawRows, mismatch[RowIndex], mismatch[ColumnName]),
                            actualRaw = GetRawValue(actualRawRows, mismatch[RowIndex], mismatch[ColumnName])
                        in
                            ParityError(
                                "Parity value mismatch",
                                [
                                    QueryIdentifier = queryIdentifier,
                                    EndpointPair = pair,
                                    Coordinate = [RowIndex = mismatch[RowIndex], ColumnName = mismatch[ColumnName]],
                                    ExpectedNormalized = mismatch[Expected],
                                    ActualNormalized = mismatch[Actual],
                                    ExpectedType = CanonicalTypeName(expectedRaw),
                                    ActualType = CanonicalTypeName(actualRaw)
                                ]
                            )
                    else true
        in
            true,

    ErrorDetailFieldEquals = (operation as function, fieldName as text, expectedValue as any) as logical =>
        let
            result = try operation(),
            detail = if result[HasError] then (try result[Error][Detail] otherwise null) else null,
            hasField = detail <> null and Record.HasFields(detail, fieldName),
            actualValue = if hasField then Record.Field(detail, fieldName) else null
        in
            hasField and actualValue = expectedValue,

    helperFacts =
    {
        Fact("ExecuteQuery Should Be a Function (Parity)", true, Value.Is(ExecuteQuery, Function.Type)),
        Fact("ExecuteQueryInGroup Should Be a Function (Parity)", true, Value.Is(ExecuteQueryInGroup, Function.Type)),
        Fact("ExecuteDaxQueries Should Be a Function (Parity)", true, Value.Is(ExecuteDaxQueries, Function.Type)),
        Fact("ExecuteDaxQueriesInGroup Should Be a Function (Parity)", true, Value.Is(ExecuteDaxQueriesInGroup, Function.Type)),
        Fact("CanonicalizeCell Should Normalize Null", "<null>", () => CanonicalizeCell(null)),
        Fact("CanonicalizeCell Should Normalize Boolean", "true", () => CanonicalizeCell(true)),
        Fact("CanonicalizeCell Should Normalize Date", "2024-01-31", () => CanonicalizeCell(#date(2024, 1, 31))),
        Fact("CanonicalizeCell Should Normalize DateTime", "2024-01-31T23:59:58", () => CanonicalizeCell(#datetime(2024, 1, 31, 23, 59, 58))),
        Fact("CanonicalizeCell Should Normalize DateTimeZone To UTC", "2024-01-31T18:30:00Z", () => CanonicalizeCell(#datetimezone(2024, 1, 31, 13, 30, 0, -5, 0))),
        Fact("CanonicalizeCell Should Normalize Numbers With Rounding Policy", "3.141592654", () => CanonicalizeCell(3.1415926536))
    },

    parityFacts =
    {

        Fact(
            "Arrow Parity TOPN1 DateID-Only Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("TopN1DateIdOnly", GetExecuteQueryCanonicalInGroup(TopN1DateIdOnlyQuery), GetExecuteDaxCanonicalInGroup(TopN1DateIdOnlyQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity TOPN1 DateID-Only Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("TopN1DateIdOnly", GetExecuteQueryCanonical(TopN1DateIdOnlyQuery), GetExecuteDaxCanonical(TopN1DateIdOnlyQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity TOPN10 DateID-Only Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("TopN10DateIdOnly", GetExecuteQueryCanonicalInGroup(TopN10DateIdOnlyQuery), GetExecuteDaxCanonicalInGroup(TopN10DateIdOnlyQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity TOPN10 DateID-Only Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("TopN10DateIdOnly", GetExecuteQueryCanonical(TopN10DateIdOnlyQuery), GetExecuteDaxCanonical(TopN10DateIdOnlyQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity TOPN10 Full Row Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("TopN10FullRow", GetExecuteQueryCanonicalInGroup(TopNDateDimQuery), GetExecuteDaxCanonicalInGroup(TopNDateDimQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity TOPN10 Full Row Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("TopN10FullRow", GetExecuteQueryCanonical(TopNDateDimQuery), GetExecuteDaxCanonical(TopNDateDimQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity Same Query TOPN10 DateDim Should Match 1 for 1",
            true,
            () => AssertCanonicalParity("SameQueryTopN10DateDim", GetExecuteQueryCanonicalInGroup(TopNDateDimQuery), GetExecuteDaxCanonicalInGroup(TopNDateDimQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity Same Query TOPN10 DateDim Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("SameQueryTopN10DateDim", GetExecuteQueryCanonical(TopNDateDimQuery), GetExecuteDaxCanonical(TopNDateDimQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity TOPN5 Text+ID Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("TopN5TextAndId", GetExecuteQueryCanonicalInGroup(TopN5TextAndIdQuery), GetExecuteDaxCanonicalInGroup(TopN5TextAndIdQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity TOPN5 Text+ID Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("TopN5TextAndId", GetExecuteQueryCanonical(TopN5TextAndIdQuery), GetExecuteDaxCanonical(TopN5TextAndIdQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity TOPN3 With BLANK Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("TopN3WithBlank", GetExecuteQueryCanonicalInGroup(TopN3WithBlankQuery), GetExecuteDaxCanonicalInGroup(TopN3WithBlankQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity TOPN3 With BLANK Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("TopN3WithBlank", GetExecuteQueryCanonical(TopN3WithBlankQuery), GetExecuteDaxCanonical(TopN3WithBlankQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity Core Types Single Row Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("CoreTypeSingleRow", GetExecuteQueryCanonicalInGroup(CoreTypeSingleRowQuery), GetExecuteDaxCanonicalInGroup(CoreTypeSingleRowQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity Core Types Single Row Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("CoreTypeSingleRow", GetExecuteQueryCanonical(CoreTypeSingleRowQuery), GetExecuteDaxCanonical(CoreTypeSingleRowQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity Core Types Multi Row Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("CoreTypeMultiRow", GetExecuteQueryCanonicalInGroup(CoreTypeMultiRowQuery), GetExecuteDaxCanonicalInGroup(CoreTypeMultiRowQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity Core Types Multi Row Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("CoreTypeMultiRow", GetExecuteQueryCanonical(CoreTypeMultiRowQuery), GetExecuteDaxCanonical(CoreTypeMultiRowQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity Empty Result Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("EmptyResult", GetExecuteQueryCanonicalInGroup(EmptyResultQuery), GetExecuteDaxCanonicalInGroup(EmptyResultQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity Empty Result Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("EmptyResult", GetExecuteQueryCanonical(EmptyResultQuery), GetExecuteDaxCanonical(EmptyResultQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity Single Row Boundary Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("SingleRowBoundary", GetExecuteQueryCanonicalInGroup(SingleRowBoundaryQuery), GetExecuteDaxCanonicalInGroup(SingleRowBoundaryQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity Single Row Boundary Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("SingleRowBoundary", GetExecuteQueryCanonical(SingleRowBoundaryQuery), GetExecuteDaxCanonical(SingleRowBoundaryQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity Wide Computed Columns Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("WideComputedColumns", GetExecuteQueryCanonicalInGroup(WideComputedColumnsQuery), GetExecuteDaxCanonicalInGroup(WideComputedColumnsQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity Wide Computed Columns Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("WideComputedColumns", GetExecuteQueryCanonical(WideComputedColumnsQuery), GetExecuteDaxCanonical(WideComputedColumnsQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity DateDim Bounded Projection Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("DateDimBoundedProjection", GetExecuteQueryCanonicalInGroup(DateDimBoundedProjectionQuery), GetExecuteDaxCanonicalInGroup(DateDimBoundedProjectionQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity DateDim Bounded Projection Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("DateDimBoundedProjection", GetExecuteQueryCanonical(DateDimBoundedProjectionQuery), GetExecuteDaxCanonical(DateDimBoundedProjectionQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity TOPN10 MarvelFact Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("TopN10MarvelFact", GetExecuteQueryCanonicalInGroup(TopN10MarvelFactQuery), GetExecuteDaxCanonicalInGroup(TopN10MarvelFactQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity TOPN10 MarvelFact Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("TopN10MarvelFact", GetExecuteQueryCanonical(TopN10MarvelFactQuery), GetExecuteDaxCanonical(TopN10MarvelFactQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity TOPN10 AlignmentDim Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("TopN10AlignmentDim", GetExecuteQueryCanonicalInGroup(TopN10AlignmentDimQuery), GetExecuteDaxCanonicalInGroup(TopN10AlignmentDimQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity TOPN10 AlignmentDim Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("TopN10AlignmentDim", GetExecuteQueryCanonical(TopN10AlignmentDimQuery), GetExecuteDaxCanonical(TopN10AlignmentDimQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity TOPN10 EyeDim Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("TopN10EyeDim", GetExecuteQueryCanonicalInGroup(TopN10EyeDimQuery), GetExecuteDaxCanonicalInGroup(TopN10EyeDimQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity TOPN10 EyeDim Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("TopN10EyeDim", GetExecuteQueryCanonical(TopN10EyeDimQuery), GetExecuteDaxCanonical(TopN10EyeDimQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity Large Multi-Batch Stream Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("LargeMultiBatch", GetExecuteQueryCanonicalInGroup(LargeMultiBatchQuery), GetExecuteDaxCanonicalInGroup(LargeMultiBatchQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity Large Multi-Batch Stream Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("LargeMultiBatch", GetExecuteQueryCanonical(LargeMultiBatchQuery), GetExecuteDaxCanonical(LargeMultiBatchQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity Unicode Text Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("UnicodeText", GetExecuteQueryCanonicalInGroup(UnicodeTextQuery), GetExecuteDaxCanonicalInGroup(UnicodeTextQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity Unicode Text Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("UnicodeText", GetExecuteQueryCanonical(UnicodeTextQuery), GetExecuteDaxCanonical(UnicodeTextQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity Mixed-Null Validity Bitmap Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("MixedNullBitmap", GetExecuteQueryCanonicalInGroup(MixedNullBitmapQuery), GetExecuteDaxCanonicalInGroup(MixedNullBitmapQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity Mixed-Null Validity Bitmap Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("MixedNullBitmap", GetExecuteQueryCanonical(MixedNullBitmapQuery), GetExecuteDaxCanonical(MixedNullBitmapQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity Large Dictionary-Encoded Stream Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("LargeDictionaryEncoded", GetExecuteQueryCanonicalInGroup(LargeDictionaryEncodedQuery), GetExecuteDaxCanonicalInGroup(LargeDictionaryEncodedQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity Large Dictionary-Encoded Stream Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("LargeDictionaryEncoded", GetExecuteQueryCanonical(LargeDictionaryEncodedQuery), GetExecuteDaxCanonical(LargeDictionaryEncodedQuery), "ExecuteQuery vs ExecuteDaxQueries")
        ),
        Fact(
            "Arrow Parity Extended Scalars Should Match ExecuteQueryInGroup",
            true,
            () => AssertCanonicalParity("ExtendedScalars", GetExecuteQueryCanonicalInGroup(ExtendedScalarQuery), GetExecuteDaxCanonicalInGroup(ExtendedScalarQuery), "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup")
        ),
        Fact(
            "Arrow Parity Extended Scalars Should Match ExecuteQuery",
            true,
            () => AssertCanonicalParity("ExtendedScalars", GetExecuteQueryCanonical(ExtendedScalarQuery), GetExecuteDaxCanonical(ExtendedScalarQuery), "ExecuteQuery vs ExecuteDaxQueries")
        )
    },

    mismatchReportingFacts =
    {
        Fact(
            "Parity Mismatch Should Report Query Identifier",
            true,
            () => ErrorDetailFieldEquals(
                () => AssertCanonicalParity(
                    "MockQueryId",
                    [Columns = {"A"}, Rows = {{"1"}}, RawRows = {[A = 1]}],
                    [Columns = {"A"}, Rows = {{"2"}}, RawRows = {[A = 2]}],
                    "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup"
                ),
                "QueryIdentifier",
                "MockQueryId"
            )
        ),
        Fact(
            "Parity Mismatch Should Report Endpoint Pair",
            true,
            () => ErrorDetailFieldEquals(
                () => AssertCanonicalParity(
                    "MockQueryId",
                    [Columns = {"A"}, Rows = {{"1"}}, RawRows = {[A = 1]}],
                    [Columns = {"A"}, Rows = {{"2"}}, RawRows = {[A = 2]}],
                    "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup"
                ),
                "EndpointPair",
                "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup"
            )
        ),
        Fact(
            "Parity Mismatch Should Report Coordinate Row Index",
            true,
            () => ErrorDetailFieldEquals(
                () => AssertCanonicalParity(
                    "MockQueryId",
                    [Columns = {"A"}, Rows = {{"1"}}, RawRows = {[A = 1]}],
                    [Columns = {"A"}, Rows = {{"2"}}, RawRows = {[A = 2]}],
                    "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup"
                ),
                "Coordinate",
                [RowIndex = 0, ColumnName = "A"]
            )
        ),
        Fact(
            "Parity Mismatch Should Report Normalized Expected Value",
            true,
            () => ErrorDetailFieldEquals(
                () => AssertCanonicalParity(
                    "MockQueryId",
                    [Columns = {"A"}, Rows = {{"1"}}, RawRows = {[A = 1]}],
                    [Columns = {"A"}, Rows = {{"2"}}, RawRows = {[A = 2]}],
                    "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup"
                ),
                "ExpectedNormalized",
                "1"
            )
        ),
        Fact(
            "Parity Mismatch Should Report Normalized Actual Value",
            true,
            () => ErrorDetailFieldEquals(
                () => AssertCanonicalParity(
                    "MockQueryId",
                    [Columns = {"A"}, Rows = {{"1"}}, RawRows = {[A = 1]}],
                    [Columns = {"A"}, Rows = {{"2"}}, RawRows = {[A = 2]}],
                    "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup"
                ),
                "ActualNormalized",
                "2"
            )
        ),
        Fact(
            "Parity Mismatch Should Report Type Metadata",
            true,
            () => ErrorDetailFieldEquals(
                () => AssertCanonicalParity(
                    "MockQueryId",
                    [Columns = {"A"}, Rows = {{"1"}}, RawRows = {[A = 1]}],
                    [Columns = {"A"}, Rows = {{"2"}}, RawRows = {[A = 2]}],
                    "ExecuteQueryInGroup vs ExecuteDaxQueriesInGroup"
                ),
                "ExpectedType",
                "number"
            )
        )
    },

    facts = if RunLiveParity then List.Combine({helperFacts, mismatchReportingFacts, parityFacts}) else List.Combine({helperFacts, mismatchReportingFacts, {Fact("RunLiveParity Must Be True For Live Parity Assertions", true, RunLiveParity)}}),

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
