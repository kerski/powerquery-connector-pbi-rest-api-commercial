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
