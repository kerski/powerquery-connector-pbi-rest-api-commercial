# GitHub Copilot Quick Start Guide

This guide shows you how to use the AIDD (AI-Driven Development) framework with GitHub Copilot in VS Code.

## Table of Contents

- [Setup](#setup)
- [Using the AIDD Agent](#using-the-aidd-agent)
  - [Invoke with @aidd](#invoke-with-aidd)
  - [Available Commands](#available-commands)
  - [Getting Started](#getting-started)
  - [Feature Development](#feature-development)
  - [Code Quality](#code-quality)
  - [Testing](#testing)
  - [Documentation & Version Control](#documentation--version-control)
- [How It Works](#how-it-works)
  - [1. Invoke the Agent](#1-invoke-the-agent)
  - [2. Agent Loads Skills](#2-agent-loads-skills)
  - [3. Skills Contain Expertise](#3-skills-contain-expertise)
  - [4. Progressive Discovery](#4-progressive-discovery)
- [Example Workflow](#example-workflow)
- [Task Management](#task-management)
  - [Epic Files](#epic-files)
  - [Epic Structure](#epic-structure)
  - [Using Epics](#using-epics)
- [Best Practices](#best-practices)
- [Available Skills](#available-skills)
- [Customization](#customization)
- [Tips & Tricks](#tips--tricks)
- [Troubleshooting](#troubleshooting)

## Setup

The AIDD framework is available as a custom agent in this repository through:
- `.github/agents/aidd.agent.md` - Custom AIDD agent
- `.github/copilot-instructions.md` - Workspace instructions (fallback)
- `ai/commands/` - Command definitions
- `ai/skills/` - Specialized skill modules
- `aidd-custom/` - Project-specific customizations

**No additional setup required!** The custom agent is automatically available when you open this repository.

## Using the AIDD Agent

### Invoke with @aidd

Open GitHub Copilot Chat (`Ctrl+Shift+I`) and type **`@aidd`** to invoke the AIDD agent.

The agent will show an argument hint:
```
Command: help | plan | discover | task | execute | review | churn | fix | test | log | commit
```

### Available Commands

Use `@aidd` followed by a command:

### Getting Started

| Command | What Happens | Example |
|---------|--------------|---------|
| `@aidd help` | Shows all available AIDD commands | `@aidd help` |
| `@aidd plan` | Reviews priorities and suggests next steps | `@aidd what's next to work on?` |

### Feature Development

| Command | What Happens | Example |
|---------|--------------|---------|
| `@aidd discover` | Interactive discovery for user journeys | `@aidd discover user onboarding flow` |
| `@aidd task` | Plans and executes task with TDD | `@aidd task: Add input validation to the API` |
| `@aidd execute` | Executes previously planned epic | `@aidd execute the my-feature epic` |

### Code Quality

| Command | What Happens | Example |
|---------|--------------|---------|
| `@aidd review` | Conducts thorough code review | `@aidd review the auth module` |
| `@aidd churn` | Identifies refactoring candidates | `@aidd show me hotspot files` |
| `@aidd fix` | Fixes bug following AIDD process | `@aidd fix the null reference in the data layer` |

### Testing

| Command | What Happens | Example |
|---------|--------------|---------|
| `@aidd user test` | Generates test scripts from user journeys | `@aidd generate user test for onboarding flow` |
| `@aidd run test` | Executes AI agent test in browser | `@aidd run the onboarding test script` |

### Documentation & Version Control

| Command | What Happens | Example |
|---------|--------------|---------|
| `@aidd log` | Documents completed work | `@aidd log the changes I just completed` |
| `@aidd commit` | Creates conventional commit message | `@aidd create a commit message` |

## How It Works

### 1. Invoke the Agent

Type `@aidd` in Copilot Chat to select the AIDD agent. You'll see it appear in the agent picker with its description and available commands.

### 2. Agent Loads Skills

When you give a command like `@aidd task: implement CLI`, the agent:
1. Reads `vision.md` first to understand project constraints
2. Reads the corresponding file from `ai/commands/task.md`
3. Loads referenced skills (e.g., `ai/skills/aidd-task-creator/SKILL.md`)
4. Follows the workflow defined in those skill files

### 3. Skills Contain Expertise

Skills are specialized modules in `ai/skills/` that contain:
- Best practices and patterns
- Domain-specific knowledge
- Step-by-step workflows
- Constraints and validation rules

Key skills include:
- **aidd-please**: General development assistant
- **aidd-task-creator**: Epic planning and execution
- **aidd-product-manager**: Feature discovery and user stories
- **aidd-tdd**: Test-driven development
- **aidd-review**: Code review process
- **aidd-fix**: Bug fixing workflow
- **aidd-javascript**: JavaScript/TypeScript best practices

### 4. Progressive Discovery

The agent only loads skills when needed:
- Start with high-level commands
- Agent reads skill files as required
- Minimizes context usage for better performance

## Example Workflow

Here's a typical development workflow using the AIDD agent:

```
@aidd plan
  → Reviews priorities and suggests next steps

@aidd discover: new user feature
  → Interactive product discovery session

@aidd task: Implement the new feature
  → Creates and executes task epic with TDD

@aidd review
  → Reviews the implementation

@aidd churn
  → Checks for refactoring opportunities

@aidd log
  → Documents changes in changelog

@aidd commit
  → Creates conventional commit message
```

## Task Management

### Epic Files

Tasks are managed as "epics" stored in `tasks/` directory:
- Location: `tasks/[epic-name]-epic.md`
- Status: PLANNED → IN-PROGRESS → COMPLETED
- Archive: Completed epics move to `tasks/archive/YYYY-MM-DD-[epic-name].md`

### Epic Structure

```markdown
# Feature Name Epic

**Status**: 📋 PLANNED
**Goal**: Brief one-line goal

## Overview

Single paragraph starting with WHY (user benefit)

---

## Task Name

Brief task description

**Requirements**:
- Given [situation], should [outcome]
- Given [situation], should [outcome]
```

### Using Epics

```
# Create and execute:
@aidd task: Add obfuscation to build process

# Execute existing epic:
@aidd execute the add-obfuscation epic

# Review epic status:
@aidd plan
```

## Project-Specific Customizations

This project has custom configuration in `aidd-custom/`:
- `config.yml` - AIDD framework settings
- `AGENTS.md` - Project-specific agent instructions
- `index.md` - Documentation of custom skills

## Vision Document

Before starting any task, agents are instructed to read `vision.md` which contains:
- Project goals and objectives
- Key constraints and non-negotiables
- Architectural decisions
- Success criteria

If a task conflicts with the vision, Copilot will flag it and ask for clarification.

## Tips

1. **Use the Agent**: Always invoke `@aidd` first
   - Type `@aidd` to see the agent in the picker
   - Or type `@aidd [command]` directly

2. **Be Specific**: More context = better results
   - ❌ `@aidd fix bug`
   - ✅ `@aidd fix: null reference in parser when handling empty M expressions`

3. **Natural After @aidd**: You can use natural language after invoking the agent
   - `@aidd review this code`
   - `@aidd help me plan a task for adding validation`
   - `@aidd what files need refactoring?`

4. **Approve Incrementally**: For complex tasks, approve each step
   - Agent will ask if you want manual approval per step
   - Or use automatic approval with review checkpoints

5. **Leverage TDD**: When implementing code, the agent follows test-driven development
   - Tests written first
   - Implementation follows tests
   - Validation before commit

6. **Review Regularly**: After every 3 tasks, the agent will:
   - Review all changes
   - Commit progress
   - Re-check alignment with epic requirements

## Troubleshooting

### Agent Not Showing Up?

1. **Check agent file exists**: `.github/agents/aidd.agent.md` should be present
2. **Reload VS Code**: `Ctrl+Shift+P` → "Developer: Reload Window"
3. **Type @aidd**: The agent should appear in the agent picker
4. **Check GitHub Copilot is active**: Look for Copilot icon in VS Code status bar

### Commands Not Triggering?

1. **Invoke the agent first**: Always start with `@aidd`
   - ❌ Just typing "task: add feature"
   - ✅ `@aidd task: add feature`

2. **Use the command keywords**: Reference the command table above
   - `@aidd help` - List commands
   - `@aidd plan` - Review priorities
   - `@aidd task` - Create/execute task
   
3. **Be explicit about the workflow**:
   ```
   @aidd use the aidd-task-creator skill to plan this feature
   ```

4. **Verify GitHub Copilot Chat is open**: `Ctrl+Shift+I` or click Copilot icon

### Skills Not Loading?

If Copilot isn't following skill guidance:
1. Explicitly reference the skill:
   ```
   Use /aidd-task-creator to plan this feature
   ```
2. Check skill file exists: `ai/skills/[skill-name]/SKILL.md`
3. Verify frontmatter in skill file has proper YAML syntax

### Epic Not Found?

Tasks directory is created on first use:
- First task command creates `tasks/` folder
- Epics are saved as `tasks/[name]-epic.md`
- Check case sensitivity in epic names

## Learning More

- **Agent File**: See `.github/agents/aidd.agent.md` for agent configuration
- **Commands**: Explore `ai/commands/` for all command definitions
- **Skills**: Browse `ai/skills/` for specialized knowledge modules
- **Vision**: Read `vision.md` for project goals and constraints
- **Framework**: Visit [AIDD Framework](https://github.com/paralleldrive/aidd)

## Need Help?

Ask the AIDD agent in Copilot Chat:
- `@aidd help` - List all commands
- `@aidd` - See available commands in agent picker
- `@aidd how do I use the task creator?`
- `@aidd explain the AIDD workflow`
