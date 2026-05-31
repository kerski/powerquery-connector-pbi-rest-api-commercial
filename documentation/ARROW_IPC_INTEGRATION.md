# Apache Arrow IPC Integration

## Overview

This document describes the Apache Arrow IPC (Inter-Process Communication) parser integration within the Power BI REST API Power Query custom connector. The Arrow parser enables native parsing of Arrow IPC binary responses from Power BI DAX query endpoints.

## Architecture

The Arrow IPC parser is implemented as a modular, isolated subsystem within the connector using native Power Query M language. It does NOT use external libraries, .NET interop, Python, or R.

### Module Structure

```
Arrow/
├── BinaryEx         - Extended binary manipulation utilities
├── Flatbuffers      - FlatBuffers parser for Arrow schema messages
├── Schema           - Arrow schema interpretation and type mapping
├── Arrays           - Array data parsers for supported types
├── RecordBatch      - Record batch parsing and buffer management
├── Detection        - Arrow format detection and validation
└── Materialization  - Conversion from Arrow IPC to Power Query tables
```

### Design Principles

1. **Isolation**: Arrow parser is completely isolated from:
   - Authentication logic
   - REST API orchestration
   - Navigation tables
   - Connector metadata
   - Transport layers

2. **Pure Function**: The parser operates as `(binary as binary) => table`

3. **Backward Compatibility**: Existing JSON responses continue to work unchanged

4. **Additive Only**: Arrow support is purely additive - no breaking changes

## Integration Points

### ExecuteDaxQueries

```powerquery
ExecuteDaxQueries(datasetId, daxQuery, ...) => any
```

**Flow:**
1. Execute Web.Contents() request with `Accept: application/vnd.apache.arrow.stream`
2. Detect response format using `Arrow[IsArrow](binary, contentType)`
3. If Arrow: Parse using `Arrow[FromBinary](binary)` → returns `table`
4. If not Arrow: Return `binary` as-is (backward compatible)

### ExecuteDaxQueriesInGroup

```powerquery
ExecuteDaxQueriesInGroup(groupId, datasetId, daxQuery, ...) => any
```

**Flow:** Same as ExecuteDaxQueries, operates on workspace-scoped datasets.

## Arrow IPC Format Detection

The parser uses two-stage detection:

### 1. Content-Type Header

Recognizes:
- `application/vnd.apache.arrow.stream`
- `application/vnd.apache.arrow.file`
- `application/octet-stream` (with magic validation)

### 2. Magic Header Validation

Validates presence of `ARROW1` magic bytes at offset 0:

```powerquery
Binary.Range(binary, 0, 6) = "ARROW1"
```

Both conditions must be satisfied for Arrow parsing to activate.

## Supported Arrow Types

| Arrow Type | Power Query Type | Parser Method |
|------------|------------------|---------------|
| Int32      | number           | ParseInt32Array |
| Int64      | number           | ParseInt64Array |
| Float64    | number           | ParseFloat64Array |
| Utf8       | text             | ParseUtf8Array |
| Boolean    | logical          | ParseBooleanArray |

### Nullable Columns

All types support nullable columns via Arrow validity bitmaps:
- Validity bitmap is read as bit-packed boolean array
- Null values are represented as `null` in Power Query

## Unsupported Features

The following Arrow features are **NOT** currently supported:

- **Compression**: LZ4, ZSTD, etc.
- **Dictionary Encoding**: Dictionary-encoded columns
- **Nested Types**: Struct, List, Map
- **Decimal128**: High-precision decimal values
- **Temporal Types**: Date32, Date64, Timestamp, Time32, Time64, Duration
- **Fixed-Size Types**: FixedSizeBinary, FixedSizeList
- **Union Types**: Dense and Sparse unions
- **Extensions**: Custom extension types

Attempting to parse unsupported types will result in structured errors.

## Binary Parsing Strategy

### Little-Endian Reading

All integer reads use little-endian byte order per Arrow specification:

```powerquery
ReadInt32LE = (data, offset) =>
    let
        bytes = Binary.Range(data, offset, 4),
        b0 = Number.From(Binary.At(bytes, 0)),
        b1 = Number.From(Binary.At(bytes, 1)),
        b2 = Number.From(Binary.At(bytes, 2)),
        b3 = Number.From(Binary.At(bytes, 3)),
        value = b0 + b1 * 256 + b2 * 65536 + b3 * 16777216
    in
        value
```

### Buffer Alignment

Arrow buffers must be aligned to 8-byte boundaries:

```powerquery
AlignOffset = (offset, alignment) =>
    let
        remainder = Number.Mod(offset, alignment),
        padding = if remainder = 0 then 0 else alignment - remainder
    in
        offset + padding
```

### Bit-Packed Booleans

Boolean arrays and validity bitmaps use bit packing (8 values per byte):

```powerquery
ReadBit = (data, byteOffset, bitOffset) =>
    let
        byte = Number.From(Binary.At(data, byteOffset)),
        mask = Number.Power(2, bitOffset),
        result = Number.Mod(Number.IntegerDivide(byte, mask), 2) = 1
    in
        result
```

## Error Handling

The parser generates structured errors with context:

```powerquery
error Error.Record(
    "Arrow.InvalidFormat",
    "Invalid Arrow IPC format: magic header 'ARROW1' not found",
    [Offset = 0]
)
```

### Error Categories

| Error Code | Description | Context |
|------------|-------------|---------|
| `Arrow.InvalidFormat` | Invalid magic header or corrupted structure | Offset |
| `Arrow.UnsupportedType` | Unsupported Arrow type encountered | Type ID |
| `Arrow.MalformedFlatbuffer` | FlatBuffer parsing failure | Field offset |
| `Arrow.InvalidOffset` | Buffer offset out of bounds | Offset, Length |
| `Arrow.TruncatedBuffer` | Incomplete buffer data | Expected, Actual |

## Performance Optimizations

### Binary.Buffer Usage

Critical for performance - buffers are read once and cached:

```powerquery
bufferedData = Binary.Buffer(data)
```

### Column-First Materialization

Arrays are materialized column-by-column (not row-by-row) for efficiency.

### Streaming Iteration

Record batches are processed using `List.Generate()` for streaming:

```powerquery
batches = List.Generate(
    () => [offset = startOffset],
    each [offset] < dataLength,
    each [offset = nextBatchOffset],
    each ParseBatch([offset])
)
```

### Avoiding Duplication

- Minimize `Binary.Range()` calls
- Avoid intermediate list copies
- Use immutable transformations

## Testing

### Unit Tests

Located in `PBIRESTAPIComm.query.pq`:

- **Detection Tests**: Magic header, content-type validation
- **BinaryEx Tests**: Int32LE, Int64LE, Float64LE, bit operations
- **Schema Tests**: Type inference for all supported types
- **Array Tests**: Parsing logic for each array type

### Golden File Tests

Test samples in `tests/samples/`:

- `arrow-magic.bin`: Minimal Arrow file with magic header
- `primitive.arrow`: Arrow file with primitive types
- `not-arrow.bin`: Non-Arrow binary for negative tests

### Integration Tests

Integration tests require live Power BI API access and are executed via CI pipeline.

## Future Extensions

The architecture is designed for extensibility:

### Planned Features

1. **Decimal128 Support**
   - Implement 128-bit decimal parsing
   - Map to Power Query number (with precision loss warning)

2. **Dictionary Encoding**
   - Parse dictionary batches
   - Resolve indices to dictionary values
   - Optimize memory for high-cardinality columns

3. **Nested Types**
   - Struct → Power Query record
   - List → Power Query list
   - Map → Power Query record with key-value pairs

4. **Compression Codecs**
   - LZ4 decompression
   - ZSTD decompression
   - Buffer codec registry

5. **Temporal Types**
   - Date32 → date
   - Date64 → date
   - Timestamp → datetime/datetimezone
   - Time32/Time64 → time
   - Duration → duration

6. **Streaming IPC**
   - Process record batches incrementally
   - Support Table.GenerateByPage for large result sets

### Extension Points

Module structure supports easy addition of new types:

```powerquery
Arrays = [
    // Existing parsers...
    ParseInt32Array = ...,
    
    // New parser
    ParseDecimal128Array = (data, offset, length, nullBitmap, nullCount) =>
        // Implementation
]
```

## Usage Examples

### Basic DAX Query with Arrow Response

```powerquery
let
    result = PBIRESTAPIComm.ExecuteDaxQueries(
        "dataset-guid",
        "EVALUATE VALUES('Product'[Category])"
    ),
    // result is automatically parsed to table if Arrow, otherwise binary
    table = if Value.Is(result, type table) then result else Json.Document(result)
in
    table
```

### Workspace-Scoped Query

```powerquery
let
    result = PBIRESTAPIComm.ExecuteDaxQueriesInGroup(
        "workspace-guid",
        "dataset-guid",
        "EVALUATE 'Sales'"
    ),
    table = if Value.Is(result, type table) then result else Json.Document(result)
in
    table
```

### Direct Arrow Parser Usage (Test Scenarios)

```powerquery
let
    arrowBinary = Extension.Contents("tests/samples/primitive.arrow"),
    table = Arrow[FromBinary](arrowBinary)
in
    table
```

## Troubleshooting

### Common Issues

#### "Invalid Arrow IPC format" Error

**Cause**: Response is not valid Arrow IPC
**Solution**: Verify Power BI service is returning Arrow format

#### "Unsupported type" Error

**Cause**: Arrow response contains unsupported type
**Solution**: Check supported types table; consider fallback to JSON

#### Performance Issues

**Cause**: Large result sets without buffering
**Solution**: Ensure `Binary.Buffer()` is applied to response

## References

- [Apache Arrow IPC Format Specification](https://arrow.apache.org/docs/format/Columnar.html)
- [Apache Arrow IPC Format (Flatbuffers)](https://github.com/apache/arrow/blob/main/format/Message.fbs)
- [Power BI REST API - Execute Queries](https://learn.microsoft.com/en-us/rest/api/power-bi/datasets/execute-queries)
- [FlatBuffers Documentation](https://google.github.io/flatbuffers/)

## Changelog

### v1.3.0 - Initial Arrow Support

- Implemented Arrow IPC stream parser
- Added support for Int32, Int64, Float64, Utf8, Boolean types
- Integrated detection and parsing into ExecuteDaxQueries/ExecuteDaxQueriesInGroup
- Added comprehensive test suite
- Maintained full backward compatibility with JSON responses
