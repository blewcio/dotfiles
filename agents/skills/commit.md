# commit

Smart git commit with safety checks and conventional commit style.

## Usage

```
/commit [-a] [-m "message"]
```

## Flags

- `-a` - Automatically stage all modified tracked files
- `-m "message"` - Skip interactive approval, use provided message directly

## Instructions

You are helping the user create a git commit following their conventions.

### Step 1: Analyze Current State

Run these commands in parallel:
- `git status` - Show all staged/unstaged changes
- `git diff --staged` - Show what will be committed
- `git log -5 --oneline` - Reference recent commit style

### Step 2: Check for Issues

- **Unrelated changes**: If staged files touch multiple unrelated features/areas, warn the user and suggest splitting into multiple commits
- **Secrets**: Check for files that might contain secrets (.env, credentials.json, .pem, .key, etc.). If found, WARN the user and refuse to commit unless they explicitly confirm
- **Empty commit**: If no changes are staged and no files are provided, inform the user

### Step 3: Draft Commit Message

Follow these rules:
- Use imperative mood: "Add", "Fix", "Update", "Refactor", "Remove", etc.
- Keep the summary line concise (50-72 characters ideal)
- Format: `<scope>: <description>` or just `<description>` if scope is obvious
- For significant changes, add a blank line and detailed description with:
  - Reasoning for the change
  - Migration notes if applicable
  - Breaking changes if any
- NEVER mention "Claude", "AI", or similar in commit messages
- Match the style of recent commits shown in git log

### Step 4: Present for Approval (unless -m flag used)

Show the user:
- Proposed commit scope and message
- List of files that will be committed
- Ask for confirmation or edits

### Step 5: Execute Commit

- If `-a` flag was used, stage all modified tracked files with `git add -u`
- Create commit using heredoc format for proper multi-line handling:

```bash
git commit -m "$(cat <<'EOF'
<commit message here>
EOF
)"
```

- After commit, run `git status` to verify success

### Step 6: Handle Hook Failures

If a pre-commit hook fails:
- Read the error message carefully
- Fix the issue (e.g., run formatter, fix linting errors)
- Create a NEW commit (NEVER use --amend unless user explicitly requests it)
- Re-run the commit process

## Examples

```bash
/commit -m "Fix typo in README"
```

```bash
/commit -a
# Interactive: reviews changes, suggests message, asks for approval
```

## Important Notes

- Keep commits focused on a single logical change
- Never skip hooks with --no-verify unless explicitly requested
- Never force operations without user approval
- If uncertain about grouping changes, ask the user
