// AUTO-GENERATED from tests/fixtures/arrow_fixtures.json by
// CI/Scripts/Emit-ArrowStaticFixtureTests.py. Do not hand-edit; re-run
// the generator to refresh. The generator is author-time only and is
// NEVER required to build the .mez connector or run the M test suite.
// Fixtures produced with pyarrow 24.0.0.
section ArrowStaticFixtureTests;

Fact = (_subject as text, _expected, _actual) as record =>
    let
        expected = if Value.Is(_expected, Function.Type) then try _expected() else try _expected,
        actual = if Value.Is(_actual, Function.Type) then try _actual() else try _actual,
        isSuccess =
            if expected[HasError] or actual[HasError] then false
            else expected[Value] = actual[Value],
        details =
            if expected[HasError] then "Expected error"
            else if actual[HasError] then "Actual error: " & (try Text.From(actual[Error][Message]) otherwise "<unknown>")
            else ""
    in
        [Result = if isSuccess then "Success" else "Failure", Notes = _subject, Details = details];

shared MyExtension.UnitTest =
[
    ArrowFromBinary = PBIRESTAPIComm.ArrowFromBinary,

    CellsEqual = (a, b) as logical =>
        if a = null and b = null then true
        else if a = null or b = null then false
        else a = b,

    RowsEqual = (actualRow as list, expectedRow as list) as logical =>
        let
            countOk = List.Count(actualRow) = List.Count(expectedRow),
            pairs = if countOk then List.Zip({actualRow, expectedRow}) else {},
            allOk = List.MatchesAll(pairs, each CellsEqual(_{0}, _{1}))
        in
            countOk and allOk,

    TableCellsMatch = (actual as table, expectedColumns as list, expectedRows as list) as logical =>
        let
            actualColumns = Table.ColumnNames(actual),
            columnsOk = actualColumns = expectedColumns,
            actualRows = if columnsOk then Table.ToRows(actual) else {},
            rowsOk = List.Count(actualRows) = List.Count(expectedRows),
            pairs = if columnsOk and rowsOk then List.Zip({actualRows, expectedRows}) else {},
            allOk = List.MatchesAll(pairs, each RowsEqual(_{0}, _{1}))
        in
            columnsOk and rowsOk and allOk,

    SimpleInt64StringHex = "ffffffffa80000001000000000000a000c000600050008000a000000000104000c00000008000800000004000800000004000000020000004400000004000000d4ffffff00000005100000001c0000000400000000000000050000004c6162656c0000000400040004000000100014000800000007000c00000010001000000000000002100000001c0000000400000000000000010000004e00000008000c0008000700080000000000000140000000ffffffffc800000014000000000000000c0016000600050008000c000c0000000003040018000000380000000000000000000a0018000c00040008000a0000006c00000010000000030000000000000000000000050000000000000000000000000000000000000000000000000000001800000000000000180000000000000000000000000000001800000000000000100000000000000028000000000000000e00000000000000000000000200000003000000000000000000000000000000030000000000000000000000000000000100000000000000020000000000000003000000000000000000000005000000090000000e000000616c7068616265746167616d6d610000ffffffff00000000",
    SimpleInt64StringBinary = Binary.FromText(SimpleInt64StringHex, BinaryEncoding.Hex),
    SimpleInt64StringTable = ArrowFromBinary(SimpleInt64StringBinary),
    SimpleInt64StringExpectedColumns = {"N", "Label"},
    SimpleInt64StringExpectedRows = {{1, "alpha"}, {2, "beta"}, {3, "gamma"}},

    NullsBitmapByteBoundaryHex = "ffffffff780000001000000000000a000c000600050008000a000000000104000c000000080008000000040008000000040000000100000014000000100014000800060007000c00000010001000000000000102100000001c0000000400000000000000010000005600000008000c0008000700080000000000000120000000ffffffff8800000014000000000000000c0016000600050008000c000c0000000003040018000000300000000000000000000a0018000c00040008000a0000003c000000100000000a000000000000000000000002000000000000000000000002000000000000000800000000000000280000000000000000000000010000000a00000000000000040000000000000055030000000000000a000000000000000c000000000000000e0000000000000010000000000000001200000013000000ffffffff00000000",
    NullsBitmapByteBoundaryBinary = Binary.FromText(NullsBitmapByteBoundaryHex, BinaryEncoding.Hex),
    NullsBitmapByteBoundaryTable = ArrowFromBinary(NullsBitmapByteBoundaryBinary),
    NullsBitmapByteBoundaryExpectedColumns = {"V"},
    NullsBitmapByteBoundaryExpectedRows = {{10}, {null}, {12}, {null}, {14}, {null}, {16}, {null}, {18}, {19}},

    MultiBatchHex = "ffffffff780000001000000000000a000c000600050008000a000000000104000c000000080008000000040008000000040000000100000014000000100014000800000007000c00000010001000000000000002100000001c0000000400000000000000010000004e00000008000c0008000700080000000000000120000000ffffffff8800000014000000000000000c0016000600050008000c000c0000000003040018000000100000000000000000000a0018000c00040008000a0000003c00000010000000030000000000000000000000020000000000000000000000000000000000000000000000000000000c0000000000000000000000010000000300000000000000000000000000000001000000020000000300000000000000ffffffff8800000014000000000000000c0016000600050008000c000c0000000003040018000000080000000000000000000a0018000c00040008000a0000003c000000100000000200000000000000000000000200000000000000000000000000000000000000000000000000000008000000000000000000000001000000020000000000000000000000000000000400000005000000ffffffff00000000",
    MultiBatchBinary = Binary.FromText(MultiBatchHex, BinaryEncoding.Hex),
    MultiBatchTable = ArrowFromBinary(MultiBatchBinary),
    MultiBatchExpectedColumns = {"N"},
    MultiBatchExpectedRows = {{1}, {2}, {3}, {4}, {5}},

    DictionaryEncodedHex = "ffffffff900000001000000000000a000c000600050008000a0000000001040004000000b8ffffff040000000100000014000000100018000800000007000c00100014001000000000000005140000004400000020000000040000000000000005000000436f6c6f720000000800080000000400080000000c00000008000c00080007000800000000000001200000000400040004000000ffffffffa800000014000000000000000c0014000600050008000c000c0000000002040014000000200000000000000008000a0000000400080000001000000000000a0018000c00040008000a0000004c0000001000000003000000000000000000000003000000000000000000000000000000000000000000000000000000100000000000000010000000000000000c000000000000000000000001000000030000000000000000000000000000000000000003000000080000000c000000726564677265656e626c756500000000ffffffff8800000014000000000000000c0016000600050008000c000c0000000003040018000000180000000000000000000a0018000c00040008000a0000003c00000010000000050000000000000000000000020000000000000000000000000000000000000000000000000000001400000000000000000000000100000005000000000000000000000000000000000000000100000002000000000000000100000000000000ffffffff00000000",
    DictionaryEncodedBinary = Binary.FromText(DictionaryEncodedHex, BinaryEncoding.Hex),
    DictionaryEncodedTable = ArrowFromBinary(DictionaryEncodedBinary),
    DictionaryEncodedExpectedColumns = {"Color"},
    DictionaryEncodedExpectedRows = {{"red"}, {"green"}, {"blue"}, {"red"}, {"green"}},

    UnicodeStringsHex = "ffffffff700000001000000000000a000c000600050008000a000000000104000c000000080008000000040008000000040000000100000014000000100014000800060007000c00000010001000000000000105100000001c00000004000000000000000400000054657874000000000400040004000000ffffffff9800000014000000000000000c0016000600050008000c000c0000000003040018000000300000000000000000000a0018000c00040008000a0000004c000000100000000400000000000000000000000300000000000000000000000000000000000000000000000000000014000000000000001800000000000000120000000000000000000000010000000400000000000000000000000000000000000000050000000e000000120000001200000000000000636166c3a9e697a5e69cace8aa9ef09f8e89000000000000ffffffff00000000",
    UnicodeStringsBinary = Binary.FromText(UnicodeStringsHex, BinaryEncoding.Hex),
    UnicodeStringsTable = ArrowFromBinary(UnicodeStringsBinary),
    UnicodeStringsExpectedColumns = {"Text"},
    UnicodeStringsExpectedRows = {{"café"}, {"日本語"}, {"🎉"}, {""}},

    BooleanWithNullHex = "ffffffff700000001000000000000a000c000600050008000a000000000104000c000000080008000000040008000000040000000100000014000000100014000800060007000c00000010001000000000000106100000001c000000040000000000000004000000466c6167000000000400040004000000ffffffff8800000014000000000000000c0016000600050008000c000c0000000003040018000000100000000000000000000a0018000c00040008000a0000003c000000100000000500000000000000000000000200000000000000000000000100000000000000080000000000000001000000000000000000000001000000050000000000000001000000000000001b000000000000000900000000000000ffffffff00000000",
    BooleanWithNullBinary = Binary.FromText(BooleanWithNullHex, BinaryEncoding.Hex),
    BooleanWithNullTable = ArrowFromBinary(BooleanWithNullBinary),
    BooleanWithNullExpectedColumns = {"Flag"},
    BooleanWithNullExpectedRows = {{true}, {false}, {null}, {true}, {false}},

    CorruptionSourceHex = SimpleInt64StringHex,
    CorruptionSourceBinary = Binary.FromText(CorruptionSourceHex, BinaryEncoding.Hex),
    CorruptionTruncatedBinary = Binary.Range(CorruptionSourceBinary, 0, 16),
    CorruptionBadHeaderBinary = Binary.Combine({Binary.FromText("00000000", BinaryEncoding.Hex), Binary.Range(CorruptionSourceBinary, 4, Binary.Length(CorruptionSourceBinary) - 4)}),

    facts =
    {
        Fact("Arrow Static Fixture [simple_int64_string] Columns Match",
            true,
            () => Table.ColumnNames(SimpleInt64StringTable) = SimpleInt64StringExpectedColumns),
        Fact("Arrow Static Fixture [simple_int64_string] Row Count Matches",
            List.Count(SimpleInt64StringExpectedRows),
            () => Table.RowCount(SimpleInt64StringTable)),
        Fact("Arrow Static Fixture [simple_int64_string] Cells Match",
            true,
            () => TableCellsMatch(SimpleInt64StringTable, SimpleInt64StringExpectedColumns, SimpleInt64StringExpectedRows)),
        Fact("Arrow Static Fixture [nulls_bitmap_byte_boundary] Columns Match",
            true,
            () => Table.ColumnNames(NullsBitmapByteBoundaryTable) = NullsBitmapByteBoundaryExpectedColumns),
        Fact("Arrow Static Fixture [nulls_bitmap_byte_boundary] Row Count Matches",
            List.Count(NullsBitmapByteBoundaryExpectedRows),
            () => Table.RowCount(NullsBitmapByteBoundaryTable)),
        Fact("Arrow Static Fixture [nulls_bitmap_byte_boundary] Cells Match",
            true,
            () => TableCellsMatch(NullsBitmapByteBoundaryTable, NullsBitmapByteBoundaryExpectedColumns, NullsBitmapByteBoundaryExpectedRows)),
        Fact("Arrow Static Fixture [multi_batch] Columns Match",
            true,
            () => Table.ColumnNames(MultiBatchTable) = MultiBatchExpectedColumns),
        Fact("Arrow Static Fixture [multi_batch] Row Count Matches",
            List.Count(MultiBatchExpectedRows),
            () => Table.RowCount(MultiBatchTable)),
        Fact("Arrow Static Fixture [multi_batch] Cells Match",
            true,
            () => TableCellsMatch(MultiBatchTable, MultiBatchExpectedColumns, MultiBatchExpectedRows)),
        Fact("Arrow Static Fixture [dictionary_encoded] Columns Match",
            true,
            () => Table.ColumnNames(DictionaryEncodedTable) = DictionaryEncodedExpectedColumns),
        Fact("Arrow Static Fixture [dictionary_encoded] Row Count Matches",
            List.Count(DictionaryEncodedExpectedRows),
            () => Table.RowCount(DictionaryEncodedTable)),
        Fact("Arrow Static Fixture [dictionary_encoded] Cells Match",
            true,
            () => TableCellsMatch(DictionaryEncodedTable, DictionaryEncodedExpectedColumns, DictionaryEncodedExpectedRows)),
        Fact("Arrow Static Fixture [unicode_strings] Columns Match",
            true,
            () => Table.ColumnNames(UnicodeStringsTable) = UnicodeStringsExpectedColumns),
        Fact("Arrow Static Fixture [unicode_strings] Row Count Matches",
            List.Count(UnicodeStringsExpectedRows),
            () => Table.RowCount(UnicodeStringsTable)),
        Fact("Arrow Static Fixture [unicode_strings] Cells Match",
            true,
            () => TableCellsMatch(UnicodeStringsTable, UnicodeStringsExpectedColumns, UnicodeStringsExpectedRows)),
        Fact("Arrow Static Fixture [boolean_with_null] Columns Match",
            true,
            () => Table.ColumnNames(BooleanWithNullTable) = BooleanWithNullExpectedColumns),
        Fact("Arrow Static Fixture [boolean_with_null] Row Count Matches",
            List.Count(BooleanWithNullExpectedRows),
            () => Table.RowCount(BooleanWithNullTable)),
        Fact("Arrow Static Fixture [boolean_with_null] Cells Match",
            true,
            () => TableCellsMatch(BooleanWithNullTable, BooleanWithNullExpectedColumns, BooleanWithNullExpectedRows)),
        Fact("Arrow Static Fixture [corruption] Truncated stream must raise",
            true,
            () => (try ArrowFromBinary(CorruptionTruncatedBinary))[HasError]),
        Fact("Arrow Static Fixture [corruption] Non-Arrow header must raise",
            true,
            () => (try ArrowFromBinary(CorruptionBadHeaderBinary))[HasError])
    }
];
