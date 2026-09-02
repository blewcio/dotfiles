---
name: project-status
description: Display current project status across all workflow phases with ticket summary and next recommended actions
compatibility: opencode
---

# Project Status Skill

Display a comprehensive overview of the current project state — workflow phase, document status, ticket progress, and recommended next actions — and update `.agents/status.md` with the current snapshot.

## Usage

Invoke this skill to check project progress:

```
"Show project status"
"Where are we?"
"Project dashboard"
"What's the current status?"
```

## Process

1. If `.agents/` doesn't exist, suggest running project-init instead — see Error Handling.
2. Read `.agents/concept.md`, `.agents/architecture.md`, `.agents/backlog.md`, and every `.agents/tickets/*.md` file. For each ticket, read its `**Status**:` line to get one of: 🟢 Ready, 🟡 In Progress, 🔵 Dev Complete, ✅ QA Pass, ❌ QA Fail, 🔴 Blocked — skip and count any file that doesn't parse.
3. Determine the current phase: **Concept** (concept.md missing or not approved) → **Architecture** (concept approved, architecture not approved) → **Planning** (architecture approved, no tickets created yet) → **Development** (tickets exist and some are incomplete) → **Delivery** (all tickets are QA Pass).
4. Count tickets by status and compute the completion percentage.
5. Rewrite `.agents/status.md` in place — same structure as the project-init template — with the current timestamp, phase, ticket counts, and next actions.
6. Display the dashboard to the user — see Output Format.

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

## Next Action Recommendations

Based on the current phase, suggest:

- **Concept**: "Start product discovery with product designer"
- **Architecture**: "Invoke software architect to design system"
- **Planning**: "Have product manager create tickets"
- **Development**: "Run QA on TICKET-XXX" (if a ticket is Dev Complete), "TICKET-XXX needs fixes" (if QA Fail), "Get next ticket" (if any are Ready), or "Review blocking dependencies" (if any are Blocked)
- **Delivery**: "All tickets complete! Review final product and ship 🚀"

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
