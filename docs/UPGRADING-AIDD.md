# Upgrading the AIDD Framework

This project uses the [AIDD (AI-Driven Development)](https://github.com/paralleldrive/aidd) framework, hosted in the `ai/` directory. The framework is maintained upstream and can be upgraded independently of your project-specific code.

## What Lives Where

| Path | Purpose | Survives Upgrade? |
|------|---------|-------------------|
| `ai/` | AIDD framework — skills, commands, scaffolds | ❌ Replaced by upgrade |
| `aidd-custom/` | Your project-specific overrides | ✅ **Always preserved** |
| `.github/agents/aidd.agent.md` | GitHub Copilot custom agent | ✅ Not touched by upgrade |
| `.github/copilot-instructions.md` | Copilot workspace instructions | ✅ Not touched by upgrade |
| `vision.md` | Your project vision | ✅ Not touched by upgrade |
| `plan.md` | Your development plan | ✅ Not touched by upgrade |
| `tasks/` | Your epics and task files | ✅ Not touched by upgrade |

---

## Upgrade Methods

### Option A — Git Subtree (Recommended)

Git subtree lets you pull the upstream `ai/` directory into this repo as a versioned commit. You can re-run it any time to pull in new skills and commands.

#### First-time setup

```bash
# Add the upstream AIDD repo as a remote (only needed once)
git remote add aidd https://github.com/paralleldrive/aidd
git fetch aidd
```

#### Upgrade

```bash
# Pull the latest ai/ directory from the upstream main branch
git subtree pull --prefix=ai aidd main --squash
```

This creates a single squash commit in your history with all the upstream changes. Resolve any merge conflicts if the upstream has changed files you have also modified locally.

#### Verify

```bash
# Confirm the ai/ directory was updated
git log --oneline -5
ls ai/skills/
```

---

### Option B — Manual Copy

If you prefer not to use git subtree, you can manually copy the `ai/` directory from the upstream repository.

```bash
# Clone the upstream AIDD repo to a temp directory
git clone https://github.com/paralleldrive/aidd /tmp/aidd-upstream

# Remove the existing ai/ directory
rm -rf ai/

# Copy the fresh ai/ directory
cp -r /tmp/aidd-upstream/ai ./ai

# Clean up
rm -rf /tmp/aidd-upstream

# Stage and commit
git add ai/
git commit -m "chore: upgrade AIDD framework to latest"
```

---

## After Upgrading

1. **Verify your customizations** — Check that `aidd-custom/` still contains your project-specific overrides. The upgrade does not touch this directory.

2. **Review breaking changes** — Check the [AIDD releases page](https://github.com/paralleldrive/aidd/releases) or `CHANGELOG.md` for any breaking changes in the new version.

3. **Test the agent** — Open GitHub Copilot Chat, type `@aidd help`, and confirm the agent responds correctly (see [TESTING-AIDD.md](TESTING-AIDD.md)).

4. **Update index files** — The `ai/**/index.md` files are auto-generated from frontmatter by a pre-commit hook. If the upstream adds new skills, their index entries will be regenerated on your next commit.

---

## GitHub Copilot Integration

The AIDD framework works alongside GitHub Copilot through two files that you own and control:

### `.github/agents/aidd.agent.md`

This file defines the `@aidd` custom agent in GitHub Copilot Chat. It contains:
- Agent name, description, and available tools
- Command routing table (e.g., "task" → load `aidd-task-creator` skill)
- Workflow protocol (read vision → load command → load skills → execute)

**This file is yours.** It is not part of the upstream `ai/` directory and is not replaced when you upgrade. You can customize it to add project-specific commands or constraints.

### `.github/copilot-instructions.md`

This file provides workspace-level instructions to all Copilot interactions (not just `@aidd`). It tells Copilot how to use the AIDD framework, which skills to load for common triggers, and where to find the vision document.

**This file is yours** and is safe to edit.

---

## Customizing AIDD for Your Project

All project-specific customization lives in `aidd-custom/`:

| File | Purpose |
|------|---------|
| `config.yml` | Framework settings (e2e tests, agent config) |
| `AGENTS.md` | Project-specific agent instructions that override `AGENTS.md` |
| `index.md` | Auto-generated index of custom skills |

To add a custom skill:
1. Create `aidd-custom/skills/my-skill/SKILL.md`
2. Reference it from a command file or the agent definition
3. The `index.md` will be regenerated on next commit

---

## Troubleshooting

### `git subtree pull` fails with "not something we can merge"

Run `git fetch aidd` first to ensure the remote is up-to-date, then retry.

### Merge conflicts in `ai/`

Resolve conflicts in favour of the upstream version unless you have intentionally modified framework files locally. If you need to customize a skill, copy it to `aidd-custom/` instead.

### Agent not appearing in Copilot Chat after upgrade

1. Check `.github/agents/aidd.agent.md` still exists and has valid YAML frontmatter.
2. Reload VS Code: `Ctrl+Shift+P` → "Developer: Reload Window".
3. See [TESTING-AIDD.md](TESTING-AIDD.md) for the full troubleshooting checklist.
