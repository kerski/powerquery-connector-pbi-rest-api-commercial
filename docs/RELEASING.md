# Releasing pq-lint

This document describes the process for creating and publishing a new release of the `pq-lint` CLI tool.

> ⚠️ **Important**: The GitHub repository **must remain private** at all times. Never push to a public fork or mirror. Artifacts are distributed exclusively through GitHub Releases and the private GitHub Packages registry.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Versioning](#versioning)
- [Release Checklist](#release-checklist)
- [Creating a Release](#creating-a-release)
- [What the Release Workflow Does](#what-the-release-workflow-does)
- [Installing from the Private Registry](#installing-from-the-private-registry)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before cutting a release you need:

| Requirement | Notes |
|---|---|
| Write access to the `kerski/pq-lint` repository | Required to push tags |
| [Bun](https://bun.sh) installed locally | For local build validation |
| [Node.js 20+](https://nodejs.org) installed locally | For obfuscation tooling |
| All CI checks passing on `main` | Never release a broken build |

---

## Versioning

This project follows [Semantic Versioning](https://semver.org) (`MAJOR.MINOR.PATCH`):

| Change type | Example | When to use |
|---|---|---|
| **PATCH** | `1.0.0 → 1.0.1` | Bug fixes, no new rules or behaviour changes |
| **MINOR** | `1.0.0 → 1.1.0` | New lint rules, new CLI commands, backwards-compatible additions |
| **MAJOR** | `1.0.0 → 2.0.0` | Breaking changes to CLI interface or rule IDs |

---

## Release Checklist

Complete every step in order before tagging:

- [ ] All tests pass on `main` (`npm test -- --no-coverage`)
- [ ] `package.json` `version` field updated to the new version
- [ ] `CHANGELOG.md` (if maintained) updated with changes for this release
- [ ] Local build validates: `npm run build:dev && node ./dist/pql-lint.js --help`
- [ ] Obfuscated artifact does not contain plaintext rule names or internal identifiers
- [ ] Changes pushed to `main` and CI is green
- [ ] Release tag pushed (triggers automated release workflow)

---

## Creating a Release

### 1. Update the version

Edit `package.json` and bump the `version` field:

```json
{
  "version": "1.1.0"
}
```

Commit and push to `main`:

```bash
git add package.json
git commit -m "chore: bump version to 1.1.0"
git push origin main
```

### 2. Wait for CI to pass

Confirm the CI workflow passes on `main` before continuing.

### 3. Create and push a version tag

Tags must follow the `v*.*.*` pattern to trigger the release workflow:

```bash
git tag v1.1.0
git push origin v1.1.0
```

### 4. Monitor the release workflow

Navigate to **Actions → Release** in the GitHub UI to monitor progress. The workflow will:

1. Run all tests (non-AI suite)
2. Build and obfuscate the CLI artifact (release mode, debug protection enabled)
3. Validate the obfuscated artifact executes
4. Upload `dist/pql-lint.js` as a GitHub Release asset
5. Publish the package to the private GitHub Packages registry (`@kerski/pq-lint`)

If any step fails, delete the tag, fix the issue, and re-tag:

```bash
git tag -d v1.1.0
git push origin :refs/tags/v1.1.0
# fix the issue, then re-tag
```

---

## What the Release Workflow Does

The `.github/workflows/release.yml` workflow runs automatically when a `v*.*.*` tag is pushed:

```
Push tag v1.1.0
      │
      ▼
Run tests
      │
      ▼
bun build ./cli/pql-lint.ts  →  dist/pql-lint.js (minified)
      │
      ▼
javascript-obfuscator (release config, debugProtection: true)
      │
      ▼
node ./dist/pql-lint.js --help  (smoke test)
      │
      ├──► Upload artifact to GitHub Release
      │
      └──► npm publish → GitHub Packages (@kerski/pq-lint)
```

**What is published to GitHub Packages:**

Only the following files are included in the npm package (defined by the `files` field in `package.json`):

| File | Description |
|---|---|
| `dist/pql-lint.js` | Obfuscated, minified CLI binary |
| `README.md` | User-facing documentation |
| `LICENSE` | Proprietary license |

Source code under `src/` or `cli/` is **never** included in the published package.

---

## Installing from the Private Registry

End users must authenticate with GitHub Packages before installing.

### 1. Create a GitHub Personal Access Token (PAT)

Generate a PAT with the `read:packages` scope at:
<https://github.com/settings/tokens>

### 2. Configure npm to use the private registry

Create or update `~/.npmrc` (global, on the user's machine):

```ini
//npm.pkg.github.com/:_authToken=YOUR_GITHUB_PAT
@kerski:registry=https://npm.pkg.github.com
```

Replace `YOUR_GITHUB_PAT` with the token generated in step 1.

### 3. Install the package

```bash
npm install -g @kerski/pq-lint
```

Or install locally in a project:

```bash
npm install @kerski/pq-lint
```

### 4. Run the CLI

After global installation:

```bash
pql-lint --help
pql-lint lint ./models
pql-lint rules
```

After local installation (via npx or bin path):

```bash
npx pql-lint lint ./models
```

### CI/CD Installation (GitHub Actions)

Use the built-in `GITHUB_TOKEN` or a scoped PAT stored as a secret:

```yaml
- name: Set up Node.js with private registry
  uses: actions/setup-node@v4
  with:
    node-version: '20'
    registry-url: 'https://npm.pkg.github.com'
    scope: '@kerski'

- name: Install pql-lint
  run: npm install -g @kerski/pq-lint
  env:
    NODE_AUTH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

- name: Lint models
  run: pql-lint lint ./models --json
```

---

## Troubleshooting

### Release workflow fails at "Run tests"

Check the test output in the Actions log. Fix failing tests on `main` before re-tagging.

### Release workflow fails at "npm publish"

- Confirm the `GITHUB_TOKEN` has `packages: write` permission. The release workflow grants this automatically via `permissions: packages: write`.
- If a package with the same version already exists in GitHub Packages, you must bump the version and create a new tag. GitHub Packages does not allow overwriting existing versions.

### "403 Forbidden" when installing the package

- Ensure your `~/.npmrc` contains a valid PAT with `read:packages` scope.
- Confirm your GitHub account has read access to the `kerski/pq-lint` repository.

### "Command not found: pql-lint" after global install

- Ensure the npm global bin directory is on your `PATH`.
- Run `npm bin -g` to find the directory and add it to `PATH`.

### "Error: Cannot find module" after install

The package requires Node.js 20 or later. Check your version:

```bash
node --version
```
