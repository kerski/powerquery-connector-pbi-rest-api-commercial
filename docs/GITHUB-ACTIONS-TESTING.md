# GitHub Actions Test Workflow

This repository uses a GitHub Actions workflow to run connector tests through the same script used in local and existing CI flows:

- Script: `CI/Scripts/Run-PQTests.ps1`
- Workflow: `.github/workflows/pq-tests.yml`

The workflow is designed for reliable, low-cost iteration by defaulting to targeted test execution.

## Goals

- Keep the default validation fast and focused.
- Run only specific test files during most development loops.
- Support an explicit full-suite mode when broader confidence is required.
- Ensure Actions and local runs stay aligned by using the same script.

## Required Repository Secrets

Set this repository secret before running the workflow:

- `TEST_CONFIG_JSON`

`TEST_CONFIG_JSON` must be a valid JSON object matching `CI/Scripts/variables.test.json` structure and include non-empty `PPU_USERNAME` and `PPU_PASSWORD` fields.

The workflow fails early if the secret is missing or invalid.

## Trigger Modes

## 1) Automatic Focused Gate (PR and push to main)

On pull requests and pushes to `main`, the workflow runs a focused parity gate test:

- `PBIRESTAPIComm.tests.datasets.parity.query.pq`

This mode compiles the connector and runs only that test file.

## 2) Manual Dispatch (Actions tab)

Use **Run workflow** for controlled runs.

Inputs:

- `test_file`: target split test file name (default: `PBIRESTAPIComm.tests.datasets.parity.query.pq`)
- `run_full_suite`: if `true`, run all split test files after the focused gate passes

Examples:

- Focused apps test only:
  - `test_file = PBIRESTAPIComm.tests.apps.query.pq`
  - `run_full_suite = false`
- Focused parity gate plus full suite:
  - `test_file = PBIRESTAPIComm.tests.datasets.parity.query.pq`
  - `run_full_suite = true`

## Reliability Components

The workflow includes reliability controls:

- Uses `windows-latest` runners to match script and tooling assumptions.
- Sets `BUILD_SOURCEVERSION` from `github.sha` so script authentication runs in non-interactive mode.
- Validates `TEST_CONFIG_JSON` before attempting test execution.
- Materializes `CI/Scripts/variables.test.json` from `TEST_CONFIG_JSON` on the runner.
- Uses one source of truth (`Run-PQTests.ps1`) to avoid drift between local, Azure Pipelines, and Actions behavior.
- Separates focused gate from full-suite run so expensive runs are explicit.

## Local Command Parity

Commands in Actions map directly to local usage:

Focused file:

```powershell
./CI/Scripts/Run-PQTests.ps1 -Compile $false -TestFileName PBIRESTAPIComm.tests.datasets.parity.query.pq
```

Full split suite:

```powershell
./CI/Scripts/Run-PQTests.ps1 -Compile $false
```

## Recommended Team Workflow

1. Use focused test files while implementing changes.
2. Keep parity gate green in pull requests.
3. Run manual full-suite only when preparing merges that affect broad surface area.
4. Investigate failures from the per-file summary table emitted by `Run-PQTests.ps1`.

## Troubleshooting

Common issues:

- Missing secret error:
  - Confirm `TEST_CONFIG_JSON` is configured in repository settings.
- Invalid JSON error:
  - Confirm `TEST_CONFIG_JSON` is valid JSON and includes `PPU_USERNAME` and `PPU_PASSWORD`.
- Auth prompt or interactive login behavior:
  - Confirm workflow env includes `BUILD_SOURCEVERSION`.
- No matching test file when manually dispatching:
  - Use exact file name from split test files, for example `PBIRESTAPIComm.tests.reports.query.pq`.
