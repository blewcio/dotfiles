---
name: next-ticket
description: Find and assign the next available ticket for development (status Ready, no blocking dependencies)
compatibility: opencode
---

# Next Ticket Skill

Find the next available ticket from the backlog that is ready for development and assign it to a developer.

## What This Skill Does

Searches `.agents/backlog.md` and `.agents/tickets/` for:
- Tickets with status "Ready" (green light 🟢)
- No blocking dependencies (or all dependencies completed)
- Prioritizes by sprint order and ticket number
- Returns ticket ID and summary for developer to claim
- Optionally updates ticket status to "Assigned"

## Usage

Invoke this skill when a developer is ready to start work:

```
"Get next ticket"
"What should I work on?"
"Assign next ticket"
"Next available task"
```

## Process

1. **Verify `.agents/` exists and has tickets**:
   - Check `.agents/backlog.md` exists
   - Check `.agents/tickets/` has ticket files

2. **Read backlog.md**:
   - Parse sprint organization
   - Identify ticket order and priorities

3. **Find ready tickets**:
   - Read each ticket file in `.agents/tickets/`
   - Check status is "Ready" (🟢)
   - Verify no blocking dependencies or all blockers are complete

4. **Prioritize tickets**:
   - Prefer earlier sprints over later
   - Within sprint, prefer lower ticket numbers
   - Respect explicit priority field (High > Medium > Low)

5. **Return ticket details**:
   - Ticket ID (e.g., TICKET-001)
   - Title
   - Sprint
   - Estimated hours
   - Brief description

6. **Optional: Mark as assigned**:
   - Update ticket status from "Ready" to "Assigned"
   - Add to workflow history

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

## Ticket Selection Algorithm

```python
def find_next_ticket():
    ready_tickets = []

    # Read all ticket files
    for ticket_file in sorted(glob('.agents/tickets/TICKET-*.md')):
        ticket = parse_ticket(ticket_file)

        # Check if ready
        if ticket.status != "Ready":
            continue

        # Check dependencies
        if ticket.blocked_by:
            all_complete = all(
                get_ticket(dep).status == "QA Pass"
                for dep in ticket.blocked_by
            )
            if not all_complete:
                continue

        ready_tickets.append(ticket)

    if not ready_tickets:
        return None

    # Sort by: sprint (asc), priority (desc), ticket_number (asc)
    ready_tickets.sort(key=lambda t: (
        t.sprint,
        priority_value(t.priority),  # High=0, Med=1, Low=2
        t.number
    ))

    return ready_tickets[0]

def priority_value(priority):
    return {"High": 0, "Medium": 1, "Low": 2}.get(priority, 3)
```

## Dependency Resolution

A ticket is ready if:
- Status field is "Ready" (🟢)
- AND (no dependencies OR all dependencies have status "QA Pass")

Check dependencies:
1. Parse "Blocked By" section in ticket file
2. For each dependency (e.g., TICKET-002):
   - Read `.agents/tickets/TICKET-002.md`
   - Check its status
   - If any dependency is not "QA Pass" or "Complete", skip this ticket

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

## Assignment Options

When returning ticket, ask user:

```
Would you like to:
1. Auto-assign to software-developer agent
2. Just view details (manual assignment)
3. Skip this ticket and see next available
```

If auto-assign:
- Update ticket file:
  ```markdown
  **Status**: 🟡 In Progress
  **Assigned**: software-developer
  ```
- Add to workflow history:
  ```
  | [Date] | Ready → Assigned | next-ticket skill | Auto-assigned via skill |
  ```

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

---

**Compatibility**: Works with both Claude Code and OpenCode (opencode compatible).
