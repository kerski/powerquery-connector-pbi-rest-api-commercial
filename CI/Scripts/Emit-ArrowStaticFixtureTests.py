"""Emit `PBIRESTAPIComm.tests.arrow.staticfixture.query.pq` from the
committed manifest at `tests/fixtures/arrow_fixtures.json`.

Author-time only. Keeps the M test file and the manifest in lock-step so
the hex bytes can never drift out of sync from their declared expected
tables. Re-run after `Generate-ArrowFixtures.py`.
"""

from __future__ import annotations

import json
import os


REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
MANIFEST = os.path.join(REPO_ROOT, "tests", "fixtures", "arrow_fixtures.json")
TARGET = os.path.join(REPO_ROOT, "PBIRESTAPIComm.tests.arrow.staticfixture.query.pq")


def m_value(v):
    """Render a Python value as an M literal."""
    if v is None:
        return "null"
    if v is True:
        return "true"
    if v is False:
        return "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, str):
        return '"' + v.replace('"', '""') + '"'
    raise TypeError(f"unsupported cell type {type(v).__name__}")


def m_row(cells):
    return "{" + ", ".join(m_value(c) for c in cells) + "}"


def m_rows(rows):
    return "{" + ", ".join(m_row(r) for r in rows) + "}"


def m_cols(cols):
    return "{" + ", ".join(m_value(c) for c in cols) + "}"


def render(manifest):
    fixtures = manifest["fixtures"]
    pyarrow_version = manifest.get("pyarrow_version", "?")

    bindings = []
    facts = []
    for fx in fixtures:
        name = fx["name"]
        cap = "".join(part.capitalize() for part in name.split("_"))
        hex_str = fx["hex"]
        cols = fx["expected"]["columns"]
        rows = fx["expected"]["rows"]

        bindings.append(f'    {cap}Hex = "{hex_str}",')
        bindings.append(f'    {cap}Binary = Binary.FromText({cap}Hex, BinaryEncoding.Hex),')
        bindings.append(f'    {cap}Table = ArrowFromBinary({cap}Binary),')
        bindings.append(f'    {cap}ExpectedColumns = {m_cols(cols)},')
        bindings.append(f'    {cap}ExpectedRows = {m_rows(rows)},')
        bindings.append("")

        facts.append(
            f'        Fact("Arrow Static Fixture [{name}] Columns Match",\n'
            f'            true,\n'
            f'            () => Table.ColumnNames({cap}Table) = {cap}ExpectedColumns)'
        )
        facts.append(
            f'        Fact("Arrow Static Fixture [{name}] Row Count Matches",\n'
            f'            List.Count({cap}ExpectedRows),\n'
            f'            () => Table.RowCount({cap}Table))'
        )
        facts.append(
            f'        Fact("Arrow Static Fixture [{name}] Cells Match",\n'
            f'            true,\n'
            f'            () => TableCellsMatch({cap}Table, {cap}ExpectedColumns, {cap}ExpectedRows))'
        )

    body = []
    body.append("// AUTO-GENERATED from tests/fixtures/arrow_fixtures.json by")
    body.append("// CI/Scripts/Emit-ArrowStaticFixtureTests.py. Do not hand-edit; re-run")
    body.append("// the generator to refresh. The generator is author-time only and is")
    body.append("// NEVER required to build the .mez connector or run the M test suite.")
    body.append(f"// Fixtures produced with pyarrow {pyarrow_version}.")
    body.append("section ArrowStaticFixtureTests;")
    body.append("")
    body.append("Fact = (_subject as text, _expected, _actual) as record =>")
    body.append("    let")
    body.append("        expected = if Value.Is(_expected, Function.Type) then try _expected() else try _expected,")
    body.append("        actual = if Value.Is(_actual, Function.Type) then try _actual() else try _actual,")
    body.append("        isSuccess =")
    body.append("            if expected[HasError] or actual[HasError] then false")
    body.append("            else expected[Value] = actual[Value],")
    body.append("        details =")
    body.append("            if expected[HasError] then \"Expected error\"")
    body.append("            else if actual[HasError] then \"Actual error: \" & (try Text.From(actual[Error][Message]) otherwise \"<unknown>\")")
    body.append("            else \"\"")
    body.append("    in")
    body.append("        [Result = if isSuccess then \"Success\" else \"Failure\", Notes = _subject, Details = details];")
    body.append("")
    body.append("shared MyExtension.UnitTest =")
    body.append("[")
    body.append("    ArrowFromBinary = PBIRESTAPIComm.ArrowFromBinary,")
    body.append("")
    body.append("    CellsEqual = (a, b) as logical =>")
    body.append("        if a = null and b = null then true")
    body.append("        else if a = null or b = null then false")
    body.append("        else a = b,")
    body.append("")
    body.append("    RowsEqual = (actualRow as list, expectedRow as list) as logical =>")
    body.append("        let")
    body.append("            countOk = List.Count(actualRow) = List.Count(expectedRow),")
    body.append("            pairs = if countOk then List.Zip({actualRow, expectedRow}) else {},")
    body.append("            allOk = List.MatchesAll(pairs, each CellsEqual(_{0}, _{1}))")
    body.append("        in")
    body.append("            countOk and allOk,")
    body.append("")
    body.append("    TableCellsMatch = (actual as table, expectedColumns as list, expectedRows as list) as logical =>")
    body.append("        let")
    body.append("            actualColumns = Table.ColumnNames(actual),")
    body.append("            columnsOk = actualColumns = expectedColumns,")
    body.append("            actualRows = if columnsOk then Table.ToRows(actual) else {},")
    body.append("            rowsOk = List.Count(actualRows) = List.Count(expectedRows),")
    body.append("            pairs = if columnsOk and rowsOk then List.Zip({actualRows, expectedRows}) else {},")
    body.append("            allOk = List.MatchesAll(pairs, each RowsEqual(_{0}, _{1}))")
    body.append("        in")
    body.append("            columnsOk and rowsOk and allOk,")
    body.append("")
    body.extend(bindings)
    # Corruption / negative-path facts. Use the first fixture (simple_int64_string)
    # as the source of truth and mutate copies to verify the parser refuses
    # malformed input rather than silently returning a wrong table.
    first = fixtures[0]
    corruption_bindings = []
    corruption_bindings.append(f'    CorruptionSourceHex = SimpleInt64StringHex,')
    corruption_bindings.append('    CorruptionSourceBinary = Binary.FromText(CorruptionSourceHex, BinaryEncoding.Hex),')
    # Truncate to the first 16 bytes — definitely not enough to contain a
    # complete Schema message, so the parser must error.
    corruption_bindings.append('    CorruptionTruncatedBinary = Binary.Range(CorruptionSourceBinary, 0, 16),')
    # Zero out the leading continuation marker so detection fails.
    corruption_bindings.append('    CorruptionBadHeaderBinary = Binary.Combine({Binary.FromText("00000000", BinaryEncoding.Hex), Binary.Range(CorruptionSourceBinary, 4, Binary.Length(CorruptionSourceBinary) - 4)}),')
    corruption_bindings.append("")
    body.extend(corruption_bindings)

    corruption_facts = []
    corruption_facts.append(
        '        Fact("Arrow Static Fixture [corruption] Truncated stream must raise",\n'
        '            true,\n'
        '            () => (try ArrowFromBinary(CorruptionTruncatedBinary))[HasError])'
    )
    corruption_facts.append(
        '        Fact("Arrow Static Fixture [corruption] Non-Arrow header must raise",\n'
        '            true,\n'
        '            () => (try ArrowFromBinary(CorruptionBadHeaderBinary))[HasError])'
    )

    body.append("    facts =")
    body.append("    {")
    body.append(",\n".join(facts + corruption_facts))
    body.append("    }")
    body.append("];")
    body.append("")
    return "\n".join(body)


def main():
    with open(MANIFEST, "r", encoding="utf-8") as f:
        manifest = json.load(f)
    text = render(manifest)
    with open(TARGET, "w", encoding="utf-8", newline="\r\n") as f:
        f.write(text)
    print(f"Wrote {TARGET} ({len(text)} chars)")


if __name__ == "__main__":
    main()
