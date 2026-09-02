---
name: next-ticket
description: Find and assign the next available ticket for development (status Ready, no blocking dependencies)
compatibility: opencode
---

# Next Ticket Skill

Find the next available ticket from the backlog that's ready for development, and optionally assign it.

## Usage

Invoke this skill when a developer is ready to start work:

```
"Get next ticket"
"What should I work on?"
"Assign next ticket"
"Next available task"
```

## Process

1. Verify `.agents/backlog.md` exists and `.agents/tickets/` has ticket files — if not, see Error Handling.
2. Read every ticket in `.agents/tickets/`. A ticket qualifies if its status is "Ready" (🟢) and every ticket in its "Blocked By" list has status "QA Pass" (tickets with no dependencies always qualify).
3. Among qualifying tickets, pick the one with the earliest sprint, then highest priority (High > Medium > Low), then lowest ticket number.
4. Report the chosen ticket — ID, title, sprint, estimate, description, acceptance criteria, dependencies — see Output Format.
5. If the user chooses to auto-assign: set status to "🟡 In Progress", set `**Assigned**: software-developer`, and log the change to the ticket's workflow history table.

If nothing qualifies, report why instead — see Handling No Available Tickets.

## Output Format

```
🎫 Next Available Ticket
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TICKET-005: Implement full-text search with FTS5

Sprint:    2 (Advanced Features)
Priority:  High
Estimate:  3 hours
Assigned:  (unassigned) → Ready to claim

Description:
Implement full-text search functionality using SQLite FTS5
extension for fast task searching across title and description.

Acceptance Criteria:
  - FTS5 virtual table created for tasks
  - Search query supports boolean operators (AND, OR)
  - Results ranked by relevance
  - Search response time < 50ms for 10,000 tasks

Dependencies: None (TICKET-002, TICKET-003 already complete)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next Steps:
1. Claim this ticket:
   "Assign TICKET-005 to software developer"

2. Or view ticket details:
   "Show TICKET-005"

3. Or skip to next:
   "Get next ticket" (will skip TICKET-005)
```

## Handling No Available Tickets

```
⚠️  No tickets available for development

Current Situation:
  - Total tickets: 19
  - Ready: 0
  - In Progress: 3
  - Blocked: 5

Possible Reasons:
  1. All ready tickets are assigned or in progress
  2. Remaining tickets are blocked by dependencies
  3. Need to wait for current tickets to complete

Blocked Tickets:
  - TICKET-008 (blocked by TICKET-005, TICKET-006)
  - TICKET-009 (blocked by TICKET-007)
  - TICKET-012 (blocked by TICKET-010)

Recommendations:
  1. Check on in-progress tickets: "Show project status"
  2. Help with QA: Review Dev Complete tickets
  3. Unblock tickets: Complete blockers first
```

## Ticket Status Reference

| Status Symbol | Status Name  | Meaning                          |
|---------------|--------------|----------------------------------|
| 🟢            | Ready        | Available to claim               |
| 🟡            | In Progress  | Developer actively working       |
| 🔵            | Dev Complete | Ready for QA review              |
| ✅            | QA Pass      | Validated and complete           |
| ❌            | QA Fail      | Needs fixes, back to development |
| 🔴            | Blocked      | Waiting on dependencies          |

## Error Handling

- **No `.agents/` directory**:
  ```
  ❌ No .agents directory found.
  Run "Initialize agent project workflow" first.
  ```

- **No tickets created yet**:
  ```
  ⚠️  No tickets found in .agents/tickets/

  You're in the PLANNING phase.
  Run "Have product manager create tickets" to generate backlog.
  ```

- **All tickets complete**:
  ```
  🎉 All tickets complete!

  Project Status: DELIVERY phase
  All 19 tickets have passed QA.

  Ready to ship! 🚀
  ```

## Integration with Other Skills

- **After this skill**: Developer invokes software-developer agent with ticket ID
- **Before this skill**: Check project-status to see overall state
- **Related skills**: transition-phase (to move between workflow phases)
