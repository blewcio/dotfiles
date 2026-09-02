---
name: transition-phase
description: Move project to the next workflow phase after validating completion of current phase and getting user approval
compatibility: opencode
---

# Transition Phase Skill

Manage transitions between workflow phases (Concept → UX/UI Design → Architecture → Planning → Development → Delivery), validating that the current phase is complete before asking the user to approve the move.

## Workflow Phases

```
CONCEPT → UX/UI DESIGN → ARCHITECTURE → PLANNING → DEVELOPMENT → DELIVERY
   ↓            ↓              ↓             ↓            ↓            ↓
product-    ux-ui-      software-    product-     software-      (Done)
designer    designer     architect     manager     developer
                                                   + qa-engineer
```

## Usage

Invoke this skill to move between phases:

```
"Move to architecture phase"
"Transition to planning"
"Start development"
"Approve concept and continue"
```

## Process

1. Detect the current phase from `.agents/status.md`, or infer it from file states if that's missing.
2. Validate that the current phase's prerequisites are met (see the phase-specific sections below) — required files exist, required sections are present, and the phase is marked "Approved by Bob". If validation fails, report exactly what's missing (see Error Handling) and stop.
3. Show the completion summary and the approval prompt for the target phase, and wait for explicit approval — no transition happens automatically, regardless of phase.
4. On approval: update `.agents/status.md`, mark the current phase's document as approved, invoke the next agent with the relevant prior documents, and append a row to Project History.
5. On denial: stay in the current phase and suggest what to revise.

## CONCEPT → UX/UI DESIGN

**Prerequisites**:
- `.agents/concept.md` exists and includes all required sections: Vision, Problem Statement, User Stories, Success Criteria, Constraints, Out of Scope
- Status marked as "Approved by Bob"
- Project involves a user interface (web, mobile, or desktop app) — otherwise see CONCEPT → ARCHITECTURE below

**User Approval Prompt**:
```
📋 Concept Phase Complete

The product concept has been documented in .agents/concept.md:
  ✅ Vision defined
  ✅ Problem statement clear
  ✅ User stories documented
  ✅ Success criteria defined
  ✅ Constraints identified

Ready to move to UX/UI Design phase?

The ux-ui-designer agent will:
  - Map user flows for key journeys
  - Create wireframes for main screens
  - Define design system (colors, typography, components)
  - Ensure accessibility compliance (WCAG AA)
  - Document interaction patterns

Approve transition to UX/UI Design? [Yes/No]

Note: For CLI-only or API-only projects without UI, skip to Architecture.
```

**On Approval**:
- Update `.agents/status.md` phase to "UX/UI DESIGN"
- Update `.agents/concept.md` status to "✅ Approved on [date]"
- Invoke ux-ui-designer agent
- Pass concept.md path to designer

---

## UX/UI DESIGN → ARCHITECTURE

**Prerequisites**:
- `.agents/design.md` exists and includes: user flows for key journeys, wireframes for main screens, design system (colors, typography, spacing), component library specifications, accessibility considerations
- Status marked as "Approved by Bob"

**User Approval Prompt**:
```
🎨 UX/UI Design Phase Complete

The interface design has been documented in .agents/design.md:
  ✅ User flows mapped
  ✅ Wireframes created
  ✅ Design system established
  ✅ Component library defined
  ✅ Accessibility requirements documented

Ready to move to Architecture phase?

The software-architect agent will:
  - Design technical architecture
  - Choose technology stack (informed by design needs)
  - Create system component design
  - Document architecture decisions (ADRs)

Approve transition to Architecture? [Yes/No]
```

**On Approval**:
- Update `.agents/status.md` phase to "ARCHITECTURE"
- Update `.agents/design.md` status to "✅ Approved on [date]"
- Invoke software-architect agent
- Pass concept.md and design.md paths to architect

---

## CONCEPT → ARCHITECTURE (Skip UX/UI Design)

**For projects without UI** (CLI tools, APIs, libraries, backend services):

**Prerequisites**:
- Same as CONCEPT → UX/UI DESIGN above
- User explicitly chooses to skip design phase

**User Approval Prompt**:
```
📋 Concept Phase Complete

This project appears to be [CLI/API/Backend].
Skip UX/UI Design and move directly to Architecture? [Yes/No]

If Yes: Proceeds to Architecture
If No: Moves to UX/UI Design phase
```

**On Approval**:
- Update `.agents/status.md` phase to "ARCHITECTURE"
- Update `.agents/concept.md` status to "✅ Approved on [date]"
- Invoke software-architect agent
- Pass concept.md path to architect

---

## ARCHITECTURE → PLANNING

**Prerequisites**:
- `.agents/architecture.md` exists and includes: tech stack decisions, system components, data model, API/interface design, non-functional requirements
- At least one ADR in `.agents/decisions/`
- Status marked as "Approved by Bob"

**User Approval Prompt**:
```
🏗️  Architecture Phase Complete

The technical architecture has been documented in .agents/architecture.md:
  ✅ Technology stack chosen
  ✅ System components designed
  ✅ Data models defined
  ✅ Interfaces specified
  ✅ Architecture decisions recorded

Ready to move to Planning phase?

The product-manager agent will:
  - Break down architecture into tickets
  - Organize tickets into sprints
  - Define acceptance criteria
  - Create dependency graph

Approve transition to Planning? [Yes/No]
```

**On Approval**:
- Update `.agents/status.md` phase to "PLANNING"
- Update `.agents/architecture.md` status to "✅ Approved on [date]"
- Invoke product-manager agent
- Pass architecture.md and concept.md paths

---

## PLANNING → DEVELOPMENT

**Prerequisites**:
- `.agents/backlog.md` exists, with at least one ticket file in `.agents/tickets/`
- Every ticket has clear acceptance criteria
- Dependencies mapped
- Status marked as "Ready for development"

**User Approval Prompt**:
```
📝 Planning Phase Complete

The project backlog has been created in .agents/backlog.md:
  ✅ [N] tickets created
  ✅ Organized into [M] sprints
  ✅ Dependencies mapped
  ✅ Acceptance criteria defined
  ✅ Estimated [X] total hours

Sprint 1: [Sprint Goal] ([N] tickets, [X] hours)
Sprint 2: [Sprint Goal] ([N] tickets, [X] hours)
...

Ready to move to Development phase?

You can:
  - Use "Get next ticket" to find available work
  - Assign tickets to software-developer agents
  - Run QA validation with qa-engineer agent

Approve transition to Development? [Yes/No]
```

**On Approval**:
- Update `.agents/status.md` phase to "DEVELOPMENT"
- Update `.agents/backlog.md` status to "✅ Ready for development"
- Display next ticket suggestion
- Show command: "Get next ticket"

---

## DEVELOPMENT → DELIVERY

**Prerequisites**:
- Every ticket in `.agents/tickets/` has status "QA Pass" or "Complete" — none remain "Ready", "In Progress", "Dev Complete", "QA Fail", or "Blocked"
- All acceptance criteria met across all tickets

**User Approval Prompt**:
```
✅ Development Phase Complete

All tickets have been implemented and validated:
  Total Tickets: [N]
  QA Pass: [N] (100%)

  Sprint 1: ✅ Complete
  Sprint 2: ✅ Complete
  Sprint 3: ✅ Complete

Ready to move to Delivery phase?

All work is complete. Time to:
  - Review the final product
  - Run end-to-end testing
  - Create release notes
  - Deploy to production

Approve transition to Delivery? [Yes/No]
```

**On Approval**:
- Update `.agents/status.md` phase to "DELIVERY"
- Mark project as complete
- Suggest next steps (release checklist, deployment, etc.)

---

## Error Handling

**Validation Failure**:
```
❌ Cannot transition to [Next Phase]

Current phase ([Current Phase]) is not complete:
  - [Validation error 1]
  - [Validation error 2]

Please complete the current phase before transitioning.

To check status: "Show project status"
```

**User Denies Approval**:
```
⏸️  Transition cancelled

Staying in [Current Phase] phase.

You can:
  - Make changes to [current phase doc]
  - Request transition again when ready
  - Check status: "Show project status"
```

**Wrong Phase Transition**:
```
⚠️  Cannot transition from [Current] directly to [Requested]

Valid transitions from [Current]:
  - [Current] → [Next Phase]

Current project phase: [Current]

To proceed: "Move to [Next Phase] phase"
```

## Project History

Record each transition in `.agents/status.md`:

```markdown
## Transition History

| Date       | From Phase    | To Phase      | Approved By | Notes              |
|------------|---------------|---------------|-------------|--------------------|
| 2026-02-20 | -             | CONCEPT       | System      | Project initialized |
| 2026-02-21 | CONCEPT       | ARCHITECTURE  | Bob         | Concept approved   |
| 2026-02-22 | ARCHITECTURE  | PLANNING      | Bob         | Architecture OK    |
| 2026-02-23 | PLANNING      | DEVELOPMENT   | Bob         | 19 tickets created |
| 2026-03-01 | DEVELOPMENT   | DELIVERY      | Bob         | All tickets QA pass |
```
