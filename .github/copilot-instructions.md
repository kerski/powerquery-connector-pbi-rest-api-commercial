<!-- rtk-instructions v2 -->
# RTK — Token-Optimized CLI

**rtk** is a CLI proxy that filters and compresses command outputs, saving 60-90% tokens.

## Rule

Always prefix shell commands with `rtk`:

```bash
# Instead of:              Use:
git status                 rtk git status
git log -10                rtk git log -10
cargo test                 rtk cargo test
docker ps                  rtk docker ps
kubectl get pods           rtk kubectl pods
```

## Meta commands (use directly)

```bash
rtk gain              # Token savings dashboard
rtk gain --history    # Per-command savings history
rtk discover          # Find missed rtk opportunities
rtk proxy <cmd>       # Run raw (no filtering) but track usage
```
<!-- /rtk-instructions -->

# AI Agent Guidelines

This project uses AI-assisted development with structured guidance in the `ai/` directory.

## Custom AIDD Agent

**Preferred Method**: Use the custom `@aidd` agent for all AIDD workflows.

The AIDD framework is available as a custom GitHub Copilot agent defined in `.github/agents/aidd.agent.md`. 

To use it:
1. Open GitHub Copilot Chat (`Ctrl+Shift+I`)
2. Type `@aidd` to invoke the agent
3. Use commands like `@aidd help`, `@aidd task`, `@aidd review`, etc.

See [COPILOT-QUICKSTART.md](../COPILOT-QUICKSTART.md) for complete command reference.

## Fallback: Natural Language Triggers

If the custom agent is not available, the following natural language triggers will load the appropriate skills:

## Vision Document Requirement

**Before creating or running any task, agents must first read the vision document (`vision.md`) in the project root.**

The vision document serves as the source of truth for:
- Project goals and objectives
- Key constraints and non-negotiables
- Architectural decisions and rationale
- User experience principles
- Success criteria

## Conflict Resolution

If any conflicts are detected between a requested task and the vision document, agents must:

1. Stop and identify the specific conflict
2. Explain how the task conflicts with the stated vision
3. Ask the user to clarify how to resolve the conflict before proceeding

Never proceed with a task that contradicts the vision without explicit user approval.

## Directory Structure and Progressive Discovery

Agents should examine the `ai/*` directory listings to understand the available commands, rules, and workflows.

Each folder in the `ai/` directory contains an `index.md` file that describes the purpose and contents of that folder. Agents can read these index files to learn the function of files in each folder without needing to read every file.

**Important:** The `ai/**/index.md` files are auto-generated from frontmatter. Do not create or edit these files manually—they will be overwritten by the pre-commit hook.

### Progressive Discovery Pattern

Agents should only consume the root index until they need subfolder contents. For example:
- If the project is Python, there is no need to read JavaScript-specific folders
- If working on backend logic, frontend UI folders can be skipped
- Only drill into subfolders when the task requires that specific domain knowledge

This approach minimizes context consumption and keeps agent responses focused.

## Custom Configuration

Project-specific customization lives in `aidd-custom/`. Before starting work:
1. Read `aidd-custom/index.md` to discover available project-specific skills
2. Read `aidd-custom/config.yml` to load configuration into context
3. Read `aidd-custom/AGENTS.md` for custom agent instructions (overrides root AGENTS.md settings)

## Invoking AIDD Commands

GitHub Copilot has built-in slash commands that cannot be overridden. To use AIDD framework commands, use natural language prompts that trigger the corresponding skills:

### Command Reference

When the user asks these questions or uses these phrases, automatically load and execute the corresponding skills:

| User Says | Action | Skills to Load |
|-----------|--------|----------------|
| "help", "list commands", "what can you do" | List all AIDD commands | `ai/skills/aidd-please/SKILL.md` |
| "plan", "what's next", "priorities" | Review plan.md and suggest next steps | `ai/skills/aidd-please/SKILL.md` |
| "discover", "user journey", "user story" | Product discovery session | `ai/skills/aidd-product-manager/SKILL.md`, `ai/skills/aidd-please/SKILL.md` |
| "task", "create epic", "plan task" | Plan and execute task epic with TDD | `ai/skills/aidd-task-creator/SKILL.md`, `ai/skills/aidd-please/SKILL.md`, `ai/skills/aidd-tdd/SKILL.md` |
| "execute epic", "run epic", "continue task" | Execute previously planned epic | `ai/skills/aidd-task-creator/SKILL.md`, `ai/skills/aidd-please/SKILL.md` |
| "review", "code review", "check quality" | Conduct thorough code review | `ai/skills/aidd-review/SKILL.md`, `ai/skills/aidd-please/SKILL.md` |
| "churn", "hotspots", "refactoring candidates" | Run churn analysis | `ai/skills/aidd-churn/SKILL.md`, `ai/skills/aidd-please/SKILL.md` |
| "fix bug", "implement feedback", "aidd fix" | Bug fixing with AIDD process | `ai/skills/aidd-fix/SKILL.md`, `ai/skills/aidd-please/SKILL.md` |
| "user test", "test script", "generate tests" | Generate test scripts from user journeys | `ai/skills/aidd-user-testing/SKILL.md`, `ai/skills/aidd-please/SKILL.md` |
| "run test", "execute test", "browser test" | Execute AI agent test | `ai/skills/aidd-user-testing/SKILL.md`, `ai/skills/aidd-please/SKILL.md` |
| "log changes", "update changelog", "document work" | Document completed epics | `ai/skills/aidd-log/SKILL.md`, `ai/skills/aidd-please/SKILL.md` |
| "commit", "create commit", "commit message" | Create conventional commit | `ai/commands/commit.md`, `ai/skills/aidd-please/SKILL.md` |

### Skill Loading Protocol

When a user request matches any command trigger:

1. **Read the vision document first**: Always check `vision.md` before starting any task
2. **Load command file**: Read the corresponding file from `ai/commands/[command-name].md`
3. **Load referenced skills**: Read all SKILL.md files referenced in the command
4. **Follow constraints**: Respect all constraints specified in the skill files
5. **Execute workflow**: Follow the workflow defined in the loaded skills

## Core Skills

When executing any command, the agent should automatically load relevant skills from `ai/skills/`. Key skills include:

- **aidd-please**: General assistant and command orchestrator
- **aidd-product-manager**: Feature planning and user journey mapping
- **aidd-task-creator**: Epic planning and execution
- **aidd-fix**: Bug fixing workflow
- **aidd-review**: Code review process
- **aidd-tdd**: Test-driven development
- **aidd-churn**: Hotspot analysis
- **aidd-javascript**: JavaScript/TypeScript best practices
- **aidd-structure**: Code organization patterns
- **aidd-log**: Changelog management

## Workflow Guidelines

1. **Read Before Acting**: Always read relevant command and skill files before executing commands
2. **Respect Constraints**: Each command file specifies constraints that must be followed
3. **Progressive Loading**: Load only the skills needed for the current task
4. **Epic Management**: Tasks are organized as epics in `$projectRoot/tasks/` directory
5. **TDD Process**: Use test-driven development when implementing code changes
6. **Documentation**: Keep documentation and epics up to date as work progresses

## Implementation Notes for Copilot

When a user request matches a command trigger (see table above):
1. Read `vision.md` first to understand project constraints
2. Read the corresponding file from `ai/commands/[command-name].md`
3. Load any skills referenced within that command file (e.g., `ai/skills/aidd-please/SKILL.md`)
4. Follow the constraints specified in the command
5. Execute the workflow defined in the skill files

Example: When user says "discover a new feature":
```
1. Read: vision.md
2. Read: ai/commands/discover.md
3. Load: ai/skills/aidd-product-manager/SKILL.md
4. Load: ai/skills/aidd-please/SKILL.md
5. Execute: Product discovery workflow with user questions
```
