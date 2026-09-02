---
name: project-status
description: Display current project status across all workflow phases with ticket summary and next recommended actions
compatibility: opencode
---

# Project Status Skill

Display a comprehensive overview of the current project state, including workflow phase, document status, ticket progress, and recommended next actions.

## What This Skill Does

Reads all state files from `.agents/` directory and generates a status dashboard showing:
- Current workflow phase (Concept → Architecture → Planning → Development → Delivery)
- Document completion status (concept.md, architecture.md, backlog.md)
- Ticket statistics (total, ready, in progress, complete, blocked)
- Next recommended actions
- Updates `.agents/status.md` with current timestamp

## Usage

Invoke this skill to check project progress:

```
"Show project status"
"Where are we?"
"Project dashboard"
"What's the current status?"
```

## Process

1. **Verify `.agents/` exists**:
   - If not found, suggest running project-init first

2. **Read all state files**:
   - `.agents/concept.md` - Check if completed and approved
   - `.agents/architecture.md` - Check if completed and approved
   - `.agents/backlog.md` - Check if tickets created
   - `.agents/tickets/*.md` - Count tickets by status

3. **Determine current phase**:
   - **Concept**: If concept.md not approved
   - **Architecture**: If concept approved but architecture not approved
   - **Planning**: If architecture approved but no tickets created
   - **Development**: If tickets exist and not all complete
   - **Delivery**: If all tickets complete

4. **Calculate ticket statistics**:
   - Count tickets by status (Ready, In Progress, Dev Complete, QA Pass, QA Fail, Blocked)
   - Calculate completion percentage

5. **Update `.agents/status.md`**:
   - Write current timestamp
   - Update phase indicator
   - Update ticket counts
   - Generate next actions

6. **Display dashboard** to user

## Output Format

```
📊 Project Status Dashboard
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current Phase: 🔄 DEVELOPMENT
Last Updated: [Timestamp]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase Progress:
  ✅ Concept      - Approved
  ✅ Architecture - Approved
  ✅ Planning     - Complete (19 tickets created)
  🔄 Development  - In Progress (8/19 complete, 42%)
  ⏳ Delivery     - Pending

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tickets Summary:
  Total:        19
  Ready:        5  🟢
  In Progress:  2  🟡
  Dev Complete: 1  🔵
  QA Pass:      8  ✅
  QA Fail:      0  ❌
  Blocked:      3  🔴

  Progress: ████████░░░░░░░░░░ 42% (8/19)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next Actions:
  1. QA review needed for TICKET-010 (Dev Complete)
  2. 5 tickets ready for development (TICKET-011-015)
  3. 3 tickets blocked, review dependencies:
     - TICKET-016 (blocked by TICKET-012)
     - TICKET-017 (blocked by TICKET-013)
     - TICKET-018 (blocked by TICKET-015)

Recommended: "Get next ticket" or "Run QA on TICKET-010"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Phase Detection Logic

```
if (!concept.md OR concept status != "Approved"):
    phase = CONCEPT
else if (!architecture.md OR architecture status != "Approved"):
    phase = ARCHITECTURE
else if (!backlog.md OR no tickets created):
    phase = PLANNING
else if (tickets exist AND incomplete tickets > 0):
    phase = DEVELOPMENT
else if (all tickets status == "QA Pass"):
    phase = DELIVERY
```

## Ticket Status Parsing

Read each `.agents/tickets/TICKET-*.md` file and extract:
- Status line: `**Status**: 🟢 Ready` → "Ready"
- Parse status markers:
  - 🟢 Ready
  - 🟡 In Progress
  - 🔵 Dev Complete
  - ✅ QA Pass / Complete
  - ❌ QA Fail
  - 🔴 Blocked

## Next Action Recommendations

Based on current state, suggest:

**Concept Phase**:
- "Start product discovery with product designer"

**Architecture Phase**:
- "Invoke software architect to design system"

**Planning Phase**:
- "Have product manager create tickets"

**Development Phase**:
- If tickets in "Dev Complete": "Run QA on TICKET-XXX"
- If tickets in "QA Fail": "TICKET-XXX needs fixes"
- If tickets are "Ready": "Get next ticket to start development"
- If tickets are "Blocked": "Review blocking dependencies"

**Delivery Phase**:
- "All tickets complete! Review final product and ship 🚀"

## Error Handling

- **No `.agents/` directory**:
  ```
  ❌ No .agents directory found.
  Run "Initialize agent project workflow" first.
  ```

- **Empty `.agents/` directory**:
  ```
  ⚠️  .agents/ directory exists but is empty.
  Run "Initialize agent project workflow" to set up templates.
  ```

- **Malformed ticket files**:
  - Skip unparseable tickets
  - Report count of skipped files

## File Update

Update `.agents/status.md` with:

```markdown
# Project Status Dashboard

**Last Updated**: [ISO 8601 timestamp]

---

## Current Phase

[Phase indicator with emoji and name]

---

## Phase Progress

[Table with phase status]

---

## Tickets Summary

[Ticket counts and progress bar]

---

## Next Actions

[Numbered list of recommended actions]

---

## Quick Commands

[Helpful command reminders]
```

---

**Compatibility**: Works with both Claude Code and OpenCode (opencode compatible).
