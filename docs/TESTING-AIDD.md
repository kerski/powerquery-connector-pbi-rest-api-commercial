# Testing the AIDD Agent

This document helps you verify the custom AIDD agent is working correctly.

## Quick Test

1. **Open GitHub Copilot Chat**
   - Press `Ctrl+Shift+I` or click the Copilot icon

2. **Type `@aidd`**
   - You should see "AIDD" appear in the agent picker
   - Description should mention "AI-Driven Development framework"

3. **Test Help Command**
   ```
   @aidd help
   ```
   
   Expected response:
   - List of all available AIDD commands
   - Emoji indicators (✅ 📋 🔍 etc.)
   - Brief description of each command

4. **Test Plan Command**
   ```
   @aidd plan
   ```
   
   Expected behavior:
   - Agent reads `vision.md`
   - Checks for `plan.md` or planning documents
   - Suggests next steps or priorities

5. **Test Task Creator (with approval)**
   ```
   @aidd task: Create a hello world function
   ```
   
   Expected workflow:
   - Agent asks clarifying questions
   - Creates an epic plan
   - Asks for approval before implementation
   - Follows TDD process if implementing code

## Verification Checklist

- [ ] `@aidd` appears in agent picker
- [ ] Agent description is visible
- [ ] `@aidd help` lists all commands
- [ ] `@aidd plan` reads vision.md
- [ ] Agent loads skills before executing commands
- [ ] Vision document is checked before tasks
- [ ] TDD process is followed for code implementation

## Troubleshooting

### Agent Not Appearing?

**Check 1**: Agent file exists
```powershell
Test-Path .github\agents\aidd.agent.md
```
Should return `True`

**Check 2**: Reload VS Code
- Press `Ctrl+Shift+P`
- Type "Developer: Reload Window"
- Press Enter

**Check 3**: Verify GitHub Copilot is active
- Look for Copilot icon in bottom status bar
- Should not show errors or warnings

### Agent Loads But Doesn't Follow Workflows?

**Check 1**: Verify skills directory structure
```powershell
Get-ChildItem ai\skills\ -Directory
```
Should show folders like `aidd-please`, `aidd-task-creator`, etc.

**Check 2**: Check skill files exist
```powershell
Get-ChildItem ai\skills\*\SKILL.md -Recurse
```
Should list multiple SKILL.md files

**Check 3**: Verify vision.md exists
```powershell
Test-Path vision.md
```
Should return `True`

## Filing Issues

If the agent still doesn't work after troubleshooting:

1. **Capture error details**:
   - What command did you use?
   - What was the expected behavior?
   - What actually happened?
   - Any error messages?

2. **Check agent configuration**:
   - Open `.github/agents/aidd.agent.md`
   - Verify YAML frontmatter is valid
   - Check for any syntax errors

3. **Verify GitHub Copilot version**:
   - Press `Ctrl+Shift+X` (Extensions)
   - Find "GitHub Copilot Chat"
   - Check version number (should be recent)

## Success!

Once verified, you can use the AIDD agent for all development workflows:
- Feature planning and discovery
- Task and epic management
- Code review and quality checks
- Bug fixing with structured process
- Test-driven development
- Changelog and commit management

See [COPILOT-QUICKSTART.md](COPILOT-QUICKSTART.md) for complete usage guide.

## Phase 11 Multi-EVALUATE Parity Commands

Use these commands to validate cross-tool parity for the DateTime two-EVALUATE probe.

1. PowerShell canonical probe:
```powershell
./CI/Scripts/Probe-MultiEvaluate.ps1 -VariablesPath .\CI\Scripts\variables.test.json -PayloadMode connector -QueryFile .\tests\fixtures\multi_evaluate_datetime_probe.dax -OutputPath .\artifacts\multi-eval-powershell-canonical.json
```

2. Python canonical probe (with token from Power BI PowerShell):
```powershell
./CI/Scripts/Run-MultiEvalPythonProbe.ps1 -PayloadMode connector -ExpectedStreams 2 -OutputPath .\artifacts\multi-eval-python-canonical.json
```

3. Compare PowerShell vs Python artifacts:
```powershell
.\.venv\Scripts\python.exe CI\Scripts\Compare-MultiEvaluateParity.py --powershell artifacts\multi-eval-powershell-canonical.json --python artifacts\multi-eval-python-canonical.json --output artifacts\multi-eval-parity-compare.json
```

4. Targeted Power Query test:
```powershell
./CI/Scripts/Run-PQTests.ps1 -Compile $false -TestFileName PBIRESTAPIComm.tests.multievaluate.datetimeprobe.query.pq
```

## Proving Multiple EVALUATE Statements Are Supported

The strongest connector-level proof is this test, which covers many same-schema
result sets AND result sets with different schemas:

```powershell
./CI/Scripts/Run-PQTests.ps1 -Compile $true -TestFileName PBIRESTAPIComm.tests.multievaluate.heterogeneous.query.pq
```

It asserts:
- 5 same-schema EVALUATE statements return a list of 5 single-row tables (one per result set).
- 3 different-schema EVALUATE statements return a list of 3 tables, each keeping its OWN schema (no column union).

If this test passes but Power BI Desktop still shows only the first table, the
loaded connector is stale/cached — not the source.

## Power BI Desktop Verification Recipe (stale-mez check)

1. Confirm which build Desktop actually loaded. In a blank query, enter:
   ```
   = PBIRESTAPIComm.Version
   ```
   The latest source build returns `2.2.0`. Any other value means the loaded
   `.mez` is stale.

2. Replace the connector and clear caches:
   - Close Power BI Desktop.
   - Manually copy the freshly built `bin\AnyCPU\Debug\powerquery-connector-pbi-rest-api-commercial.mez`
     to your Power BI Desktop Custom Connectors folder (typically under OneDrive-redirected Documents; remove older copies).
   - Reopen Power BI Desktop.

3. Reproduce multiple EVALUATE in a blank query (replace the IDs):
   ```
   = PBIRESTAPIComm.ExecuteDaxQueriesInGroup(
       "<workspace-id>",
       "<dataset-id>",
       "EVALUATE ROW(""Alpha"", 1)#(lf)EVALUATE ROW(""Beta"", 2)#(lf)EVALUATE ROW(""Gamma"", 3)"
   )
   ```
   Expected: a **list of 3 tables**, one per EVALUATE result set — item 0 has
   column `[Alpha]`, item 1 has `[Beta]`, item 2 has `[Gamma]`. Each item keeps
   its own schema (no column union). Expand an item to see its rows.

4. If you still see unexpected behavior with a confirmed `2.2.0` build,
   capture the raw server response to determine whether the server itself
   returned unexpected content:
   ```powershell
   ./CI/Scripts/Capture-ArrowResponse.ps1
   ```

