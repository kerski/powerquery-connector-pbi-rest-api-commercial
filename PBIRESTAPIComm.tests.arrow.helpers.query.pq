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
    ArrowDetectionGetContentType = PBIRESTAPIComm.ArrowDetectionGetContentType,
    ArrowDetectionIsArrowContentType = PBIRESTAPIComm.ArrowDetectionIsArrowContentType,
    ArrowDetectionHasArrowMagic = PBIRESTAPIComm.ArrowDetectionHasArrowMagic,
    ArrowDetectionIsArrowResponse = PBIRESTAPIComm.ArrowDetectionIsArrowResponse,
    ArrowBinaryExBuffer = PBIRESTAPIComm.ArrowBinaryExBuffer,
    ArrowBinaryExSlice = PBIRESTAPIComm.ArrowBinaryExSlice,
    ArrowBinaryExLength = PBIRESTAPIComm.ArrowBinaryExLength,
    ArrowFromBinary = PBIRESTAPIComm.ArrowFromBinary,
    ArrowReadUInt8 = PBIRESTAPIComm.ArrowReadUInt8,
    ArrowTestRaise = PBIRESTAPIComm.ArrowTestRaise,

    GetError = (operation as function) as nullable record =>
        let
            attempt = try operation()
        in
            if attempt[HasError] then attempt[Error] else null,

    ErrorMessageContains = (operation as function, expectedText as text) as logical =>
        let
            err = GetError(operation),
            msg = if err = null then "" else (try Text.From(err[Message]) otherwise "")
        in
            Text.Contains(msg, expectedText),

    ErrorDetailFieldEquals = (operation as function, fieldName as text, expectedValue as any) as logical =>
        let
            err = GetError(operation),
            detail = if err = null then null else (try err[Detail] otherwise null),
            hasField = detail <> null and Record.HasFields(detail, fieldName),
            actualValue = if hasField then Record.Field(detail, fieldName) else null
        in
            hasField and actualValue = expectedValue,

    OperationHasError = (operation as function) as logical =>
        let
            attempt = try operation()
        in
            attempt[HasError],

    ArrowMagicHex = "4152524f5731",
    ArrowMagicBytes = Binary.FromText(ArrowMagicHex, BinaryEncoding.Hex),
    NonArrowBytes = Text.ToBinary("not-arrow"),
    TailArrowBytes = Binary.Combine({Text.ToBinary("prefix"), ArrowMagicBytes}),
    BinarySample = Binary.FromText("00010203040506070809", BinaryEncoding.Hex),
    BinarySampleSliceExpected = Binary.FromText("020304", BinaryEncoding.Hex),
    EmptyBinary = Text.ToBinary(""),
    Lz4MagicBytes = Binary.FromText("04224d18", BinaryEncoding.Hex),
    MalformedArrowLikeBytes = Binary.Combine({ArrowMagicBytes, Text.ToBinary("broken")}),
    TruncatedArrowLikeBytes = Binary.FromText("ffffffff", BinaryEncoding.Hex),
    Lz4WithArrowTailBytes = Binary.Combine({Lz4MagicBytes, Text.ToBinary("bad"), ArrowMagicBytes}),

    ArrowHeaders = [#"Content-Type" = "application/vnd.apache.arrow.stream"],
    ArrowHeadersWithCharset = [#"Content-Type" = "application/vnd.apache.arrow.file; charset=utf-8"],
    ArrowHeadersLowercase = [#"content-type" = "application/octet-stream"],
    JsonHeaders = [#"Content-Type" = "application/json"],

    facts =
    {
        Fact("ArrowDetectionGetContentType Should Be a Function", true, Value.Is(ArrowDetectionGetContentType, Function.Type)),
        Fact("ArrowDetectionIsArrowContentType Should Be a Function", true, Value.Is(ArrowDetectionIsArrowContentType, Function.Type)),
        Fact("ArrowDetectionHasArrowMagic Should Be a Function", true, Value.Is(ArrowDetectionHasArrowMagic, Function.Type)),
        Fact("ArrowDetectionIsArrowResponse Should Be a Function", true, Value.Is(ArrowDetectionIsArrowResponse, Function.Type)),
        Fact("ArrowBinaryExBuffer Should Be a Function", true, Value.Is(ArrowBinaryExBuffer, Function.Type)),
        Fact("ArrowBinaryExSlice Should Be a Function", true, Value.Is(ArrowBinaryExSlice, Function.Type)),
        Fact("ArrowBinaryExLength Should Be a Function", true, Value.Is(ArrowBinaryExLength, Function.Type)),
        Fact("ArrowFromBinary Should Be a Function", true, Value.Is(ArrowFromBinary, Function.Type)),

        Fact(
            "ArrowDetectionGetContentType Should Normalize Header Value",
            "application/vnd.apache.arrow.file",
            () => ArrowDetectionGetContentType(ArrowHeadersWithCharset)
        ),
        Fact(
            "ArrowDetectionGetContentType Should Read Lowercase Header Key",
            "application/octet-stream",
            () => ArrowDetectionGetContentType(ArrowHeadersLowercase)
        ),
        Fact(
            "ArrowDetectionGetContentType Should Return Null When Header Missing",
            null,
            () => ArrowDetectionGetContentType([])
        ),

        Fact(
            "ArrowDetectionIsArrowContentType Should Return True For Arrow Header",
            true,
            () => ArrowDetectionIsArrowContentType(ArrowHeaders)
        ),
        Fact(
            "ArrowDetectionIsArrowContentType Should Return False For Json Header",
            false,
            () => ArrowDetectionIsArrowContentType(JsonHeaders)
        ),

        Fact(
            "ArrowDetectionHasArrowMagic Should Return True For Header Magic",
            true,
            () => ArrowDetectionHasArrowMagic(ArrowMagicBytes)
        ),
        Fact(
            "ArrowDetectionHasArrowMagic Should Return True For Tail Magic",
            true,
            () => ArrowDetectionHasArrowMagic(TailArrowBytes)
        ),
        Fact(
            "ArrowDetectionHasArrowMagic Should Return False For Non Arrow Payload",
            false,
            () => ArrowDetectionHasArrowMagic(NonArrowBytes)
        ),

        Fact(
            "ArrowDetectionIsArrowResponse Should Return True When Magic Present",
            true,
            () => ArrowDetectionIsArrowResponse(ArrowMagicBytes, JsonHeaders)
        ),
        Fact(
            "ArrowDetectionIsArrowResponse Should Return True When Arrow Content Type Present",
            true,
            () => ArrowDetectionIsArrowResponse(NonArrowBytes, ArrowHeaders)
        ),
        Fact(
            "ArrowDetectionIsArrowResponse Should Return False When Neither Signal Present",
            false,
            () => ArrowDetectionIsArrowResponse(NonArrowBytes, JsonHeaders)
        ),

        Fact(
            "Detection Failure Should Include Helper Name In Stage Context",
            true,
            () => ErrorDetailFieldEquals(
                () => ArrowTestRaise("Arrow detection failed", "Arrow.Detection", "IsArrowResponse", [Reason = "NoMagicAndNoContentType"]),
                "Stage",
                "IsArrowResponse"
            )
        ),
        Fact(
            "Detection Failure Should Include Reason Context",
            true,
            () => ErrorDetailFieldEquals(
                () => ArrowTestRaise("Arrow detection failed", "Arrow.Detection", "IsArrowResponse", [Reason = "NoMagicAndNoContentType"]),
                "Reason",
                "NoMagicAndNoContentType"
            )
        ),
        Fact(
            "Binary Boundary Failure Should Include Offset Context",
            true,
            () => ErrorDetailFieldEquals(() => ArrowReadUInt8(Text.ToBinary(""), 3), "Offset", 3)
        ),
        Fact(
            "Binary Boundary Failure Should Include Length Context",
            true,
            () => ErrorDetailFieldEquals(() => ArrowReadUInt8(Text.ToBinary(""), 3), "Length", 0)
        ),
        Fact(
            "Unsupported Compression Failure Should Include Compression Identifier",
            true,
            () => ErrorDetailFieldEquals(
                () => ArrowTestRaise("Compressed Arrow bodies are not supported", "Arrow.RecordBatch", "Compression", [Compression = "LZ4_FRAME"]),
                "Compression",
                "LZ4_FRAME"
            )
        ),
        Fact(
            "Malformed Payload Failure Should Include Parse Stage Context",
            true,
            () => ErrorDetailFieldEquals(
                () => ArrowTestRaise("Malformed Arrow payload", "Arrow.Stream", "Metadata", [Reason = "InvalidFlatbufferMessage"]),
                "Stage",
                "Metadata"
            )
        ),
        Fact(
            "Malformed Payload Failure Should Expose Error Message",
            true,
            () => ErrorMessageContains(
                () => ArrowTestRaise("Malformed Arrow payload", "Arrow.Stream", "Metadata", [Reason = "InvalidFlatbufferMessage"]),
                "Malformed Arrow payload"
            )
        ),

        Fact(
            "ArrowBinaryExSlice Should Return Exact Bytes For Valid Window",
            Binary.ToText(BinarySampleSliceExpected, BinaryEncoding.Hex),
            () => Binary.ToText(ArrowBinaryExSlice(BinarySample, 2, 3), BinaryEncoding.Hex)
        ),
        Fact(
            "ArrowBinaryExSlice Should Fail Deterministically For Out Of Bounds",
            true,
            () => OperationHasError(() => ArrowBinaryExSlice(BinarySample, 200, 2))
        ),
        Fact(
            "ArrowBinaryExBuffer Should Preserve Byte Identity",
            Binary.ToText(BinarySample, BinaryEncoding.Hex),
            () => Binary.ToText(ArrowBinaryExBuffer(BinarySample), BinaryEncoding.Hex)
        ),
        Fact(
            "ArrowBinaryExLength Should Return Correct Length For Empty Binary",
            0,
            () => ArrowBinaryExLength(EmptyBinary)
        ),
        Fact(
            "ArrowBinaryExLength Should Return Correct Length For Non Empty Binary",
            10,
            () => ArrowBinaryExLength(BinarySample)
        ),

        Fact(
            "ArrowFromBinary Should Fail Fast For Unsupported Compression Signature",
            true,
            () => ErrorMessageContains(() => ArrowFromBinary(Lz4WithArrowTailBytes), "Unsupported compression")
        ),
        Fact(
            "ArrowFromBinary Unsupported Compression Should Include Compression Identifier",
            true,
            () => ErrorDetailFieldEquals(() => ArrowFromBinary(Lz4WithArrowTailBytes), "Compression", "LZ4_FRAME")
        ),
        Fact(
            "ArrowFromBinary Should Fail Deterministically For Malformed Arrow Stream",
            true,
            () => ErrorMessageContains(() => ArrowFromBinary(MalformedArrowLikeBytes), "Arrow parse failed")
        ),
        Fact(
            "ArrowFromBinary Should Fail For Truncated Payload Without Partial Output",
            true,
            () => OperationHasError(() => ArrowFromBinary(TruncatedArrowLikeBytes))
        ),
        Fact(
            "ArrowFromBinary Should Reject Invalid Framing Before RecordBatch Parse",
            true,
            () => ErrorDetailFieldEquals(() => ArrowFromBinary(NonArrowBytes), "Stage", "Framing")
        )
    },

    results = Table.ReverseRows(Table.FromRecords(facts)),
    results2 = Table.SelectRows(results, each Text.StartsWith([Result], "F"))
][results2];
