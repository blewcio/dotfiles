# Autonomous Multi-Agent Product Team

An autonomous system of AI agents that collaboratively handle the complete software development lifecycle, from product concept to delivery.

## Overview

This system provides 6 specialized agents that work together like a real product team:

| Agent | Role | Responsibility |
|-------|------|----------------|
| **product-designer** | Product Design | Captures product vision, defines user stories, creates concept documents |
| **ux-ui-designer** | UX/UI Design | Creates wireframes, user flows, design systems, ensures accessibility |
| **software-architect** | Technical Design | Designs architecture, chooses tech stack, creates ADRs |
| **product-manager** | Project Management | Breaks down work into tickets, manages backlog, tracks progress |
| **software-developer** | Development | Implements tickets, writes tests, follows architecture patterns |
| **qa-engineer** | Quality Assurance | Validates work, runs tests, ensures quality standards |

## Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│ Phase 1: CONCEPT                                                │
│ Bob + product-designer → concept.md                             │
│                                              ↓ [Bob Approves]   │
├─────────────────────────────────────────────────────────────────┤
│ Phase 2: UX/UI DESIGN                                           │
│ ux-ui-designer reads concept → design.md + wireframes/         │
│                                       ↓ [Bob Approves]          │
├─────────────────────────────────────────────────────────────────┤
│ Phase 3: ARCHITECTURE                                           │
│ software-architect reads concept+design → architecture.md+ADRs  │
│                                       ↓ [Bob Approves]          │
├─────────────────────────────────────────────────────────────────┤
│ Phase 4: PLANNING                                               │
│ product-manager reads architecture → backlog.md + tickets/*.md  │
│                                      ↓ [Bob Approves]           │
├─────────────────────────────────────────────────────────────────┤
│ Phase 5: DEVELOPMENT (Iterative)                                │
│ ┌───────────────────────────────────────────────────┐           │
│ │ software-developer claims ticket → implements     │           │
│ │                                  ↓                │           │
│ │ qa-engineer validates → [PASS] → ticket complete  │           │
│ │                       → [FAIL] → back to dev      │           │
│ └───────────────────────────────────────────────────┘           │
│ Repeat until all tickets complete ↓                             │
├─────────────────────────────────────────────────────────────────┤
│ Phase 6: DELIVERY                                               │
│ All tickets complete → Bob reviews final product → Ship! 🚀     │
└─────────────────────────────────────────────────────────────────┘
```

**Note**: For CLI-only, API, or backend projects without UI, you can skip Phase 2 (UX/UI Design) and go directly from Concept to Architecture.

## Quick Start

### 1. Initialize a New Project

```bash
cd ~/projects/my-new-app
```

Then say to Claude:
```
"Initialize agent project workflow"
```

This creates the `.agents/` directory structure:
```
.agents/
├── concept.md              # Product concept (product-designer output)
├── architecture.md         # Technical design (software-architect output)
├── backlog.md             # Master ticket list (product-manager output)
├── status.md              # Project dashboard
├── tickets/               # Individual ticket files
│   ├── TICKET-001.md
│   ├── TICKET-002.md
│   └── ...
└── decisions/             # Architecture Decision Records (ADRs)
    ├── 001-tech-stack.md
    └── ...
```

### 2. Concept Phase - Define Product Vision

Work with the product designer to capture your idea:

```
"I want to discuss my project idea with the product designer"
```

The product-designer agent will:
- Ask clarifying questions about the problem you're solving
- Define user stories and success criteria
- Identify constraints and assumptions
- Create `.agents/concept.md`

**You review and approve** the concept before moving forward.

### 3. Architecture Phase - Design Technical Solution

Transition to architecture:

```
"The concept looks good, move to architecture phase"
```

The software-architect agent will:
- Read the approved concept
- Design system architecture
- Choose appropriate technology stack
- Create Architecture Decision Records (ADRs)
- Generate `.agents/architecture.md`

**You review and approve** the architecture.

### 4. Planning Phase - Create Tickets

Transition to planning:

```
"Architecture approved, create tickets"
```

The product-manager agent will:
- Break down architecture into small tickets (2-8 hours each)
- Organize tickets into logical sprints
- Define clear acceptance criteria
- Map dependencies between tickets
- Create `.agents/backlog.md` and `.agents/tickets/TICKET-*.md`

**You review and approve** the backlog.

### 5. Development Phase - Build the Product

Check what to work on:

```
"Show project status"
```

Get next ticket:

```
"Get next ticket"
```

Assign to developer:

```
"Assign TICKET-001 to software developer"
```

The software-developer agent will:
- Read ticket requirements
- Follow architecture patterns
- Write clean, tested code
- Update ticket status
- Mark as "Dev Complete" when ready

Run QA validation:

```
"Run QA on TICKET-001"
```

The qa-engineer agent will:
- Validate against acceptance criteria
- Run all tests
- Check code quality
- Mark as "QA Pass" or "QA Fail" with feedback

Repeat until all tickets are complete!

### 6. Delivery Phase - Ship It!

When all tickets pass QA:

```
"Show project status"
```

Output:
```
🎉 All tickets complete!
Project Status: DELIVERY phase
Ready to ship! 🚀
```

## Available Skills

### project-init
Initialize `.agents/` directory structure for new projects.

**Usage**: `"Initialize agent project workflow"`

### project-status
Display current phase, ticket progress, and next actions.

**Usage**: `"Show project status"` or `"Where are we?"`

### next-ticket
Find the next available ticket ready for development.

**Usage**: `"Get next ticket"` or `"What should I work on?"`

### transition-phase
Move between workflow phases with validation and approval.

**Usage**: `"Move to architecture phase"` or `"Start development"`

## Agent Details

### product-designer

**When to use**: Starting a new project, need to clarify product vision

**Invocation**:
```
"I want to discuss my project idea with the product designer"
"Help me define the product concept"
```

**Output**: `.agents/concept.md` with vision, user stories, success criteria

**Key behaviors**:
- Asks clarifying questions about user needs
- Focuses on problems, not solutions
- Validates assumptions
- Defines realistic scope for v1

---

### ux-ui-designer

**When to use**: After concept is approved, for projects with user interfaces (web, mobile, desktop apps)

**Invocation**:
```
"Move to UX/UI design phase"
"Have the UX/UI designer create wireframes"
```

**Output**: `.agents/design.md` with user flows, wireframes, design system

**Key behaviors**:
- Maps user flows for key journeys
- Creates wireframes for main screens
- Defines design system (colors, typography, components)
- Ensures WCAG AA accessibility compliance
- Documents interaction patterns and states
- Considers responsive design across devices

**Skip for**: CLI tools, APIs, libraries, backend services without UI

---

### software-architect

**When to use**: After concept is approved, need technical design

**Invocation**:
```
"Move to architecture phase"
"Have the software architect design the system"
```

**Output**: `.agents/architecture.md` + `.agents/decisions/*.md` (ADRs)

**Key behaviors**:
- Considers multiple technical approaches
- Documents tradeoff analysis in ADRs
- Prefers proven over cutting-edge technology
- Designs for the scope defined in concept

---

### product-manager

**When to use**: After architecture is approved, need work breakdown

**Invocation**:
```
"Move to planning phase"
"Have the product manager create tickets"
```

**Output**: `.agents/backlog.md` + `.agents/tickets/TICKET-*.md`

**Key behaviors**:
- Creates small, focused tickets (2-8 hours each)
- Maps dependencies between tickets
- Organizes into logical sprints
- Defines clear acceptance criteria with test requirements

---

### software-developer

**When to use**: Implementing tickets during development phase

**Invocation**:
```
"Assign TICKET-005 to software developer"
"Have developer implement the next ticket"
```

**Updates**: Ticket status (Ready → In Progress → Dev Complete)

**Key behaviors**:
- Follows architecture patterns
- Writes clean, tested code
- Includes inline comments for complex logic
- Updates ticket with implementation notes

**Note**: Can run multiple developers in parallel on different tickets.

---

### qa-engineer

**When to use**: Validating completed development work

**Invocation**:
```
"Run QA on TICKET-005"
"Validate the completed ticket"
```

**Updates**: Ticket status (Dev Complete → QA Pass/QA Fail)

**Key behaviors**:
- Validates against acceptance criteria
- Runs automated and manual tests
- Checks code quality and security
- Provides detailed feedback if failing

---

## Project State Files

### .agents/concept.md
Product vision, user stories, success criteria, constraints.
Created by **product-designer**, approved by you.

### .agents/design.md
User flows, wireframes, design system, component library, accessibility specs.
Created by **ux-ui-designer**, approved by you. (Skip for CLI/API projects)

### .agents/architecture.md
Tech stack, system design, data models, interfaces, non-functional requirements.
Created by **software-architect**, approved by you.

### .agents/backlog.md
Master list of all tickets organized by sprint with dependencies.
Created by **product-manager**, approved by you.

### .agents/tickets/TICKET-NNN.md
Individual ticket with description, acceptance criteria, test plan, status.
Created by **product-manager**, updated by **software-developer** and **qa-engineer**.

### .agents/decisions/NNN-title.md
Architecture Decision Records documenting major technical choices.
Created by **software-architect**.

### .agents/status.md
Real-time dashboard of project phase, progress, and next actions.
Updated by **project-status** skill.

## Ticket Workflow

```
🟢 Ready
  ↓ (developer claims)
🟡 In Progress
  ↓ (implementation complete)
🔵 Dev Complete
  ↓ (QA validation)
┌─────┴─────┐
↓           ↓
✅ QA Pass   ❌ QA Fail
(complete)  (back to In Progress)
```

**Statuses**:
- **🟢 Ready**: Available to claim, no blocking dependencies
- **🟡 In Progress**: Developer actively working
- **🔵 Dev Complete**: Implementation done, ready for QA
- **✅ QA Pass**: Validated and complete
- **❌ QA Fail**: Issues found, needs fixes
- **🔴 Blocked**: Waiting on dependencies

## Example Sessions

### Example 1: CLI Tool (Skip UX/UI Design)

Building a command-line task manager:

```
You: "Initialize agent project workflow"
→ Creates .agents/ directory

You: "I want to build a task manager CLI with the product designer"
Designer: "What problem are you trying to solve? Who are the users?"
[Discovery conversation...]
Designer: Creates .agents/concept.md
You: Review and approve

You: "Move to architecture phase"  # Skips UX/UI design (no GUI)
Architect: Reads concept, designs Rust-based CLI with SQLite
Architect: Creates .agents/architecture.md + ADRs
You: Review and approve

You: "Move to planning phase"
PM: Breaks down into 19 tickets across 4 sprints
PM: Creates .agents/backlog.md + ticket files
You: Review and approve

You: "Get next ticket"
→ Returns TICKET-001: Project scaffolding

You: "Assign TICKET-001 to software developer"
Developer: Implements Cargo setup, CLI skeleton
Developer: Marks Dev Complete

You: "Run QA on TICKET-001"
QA: Validates acceptance criteria, runs tests
QA: Marks QA Pass

You: "Get next ticket"
→ Returns TICKET-002: SQLite schema

[Continue until all tickets complete...]

You: "Show project status"
→ "All tickets complete! Ready to ship! 🚀"
```

### Example 2: Web App (With UX/UI Design)

Building a web-based productivity dashboard:

```
You: "Initialize agent project workflow"
→ Creates .agents/ directory

You: "I want to build a productivity dashboard web app with the product designer"
Designer: "What problem are you trying to solve? Who are the users?"
[Discovery conversation...]
Designer: Creates .agents/concept.md
You: Review and approve

You: "Move to UX/UI design phase"
UX/UI Designer: Creates user flows for task management, calendar, focus mode
UX/UI Designer: Designs wireframes for main dashboard, settings, task detail views
UX/UI Designer: Defines design system (colors, typography, component library)
UX/UI Designer: Creates .agents/design.md + wireframe descriptions
You: Review and approve

You: "Move to architecture phase"
Architect: Reads concept + design, chooses React + Tailwind + Supabase
Architect: Designs component architecture informed by wireframes
Architect: Creates .agents/architecture.md + ADRs
You: Review and approve

You: "Move to planning phase"
PM: Breaks down into tickets referencing specific wireframes
PM: Creates .agents/backlog.md + ticket files
You: Review and approve

[Development phase same as Example 1...]

You: "Show project status"
→ "All tickets complete! Ready to ship! 🚀"
```

## Tips

### Start Small
Begin with a simple project to learn the workflow before tackling complex systems.

### Review Each Phase
Take time to review and refine each phase document. Good concept → better architecture → cleaner tickets.

### Use Status Checks
Run `"Show project status"` frequently to see progress and next actions.

### Trust the Process
The agents follow established software engineering practices. Let them guide the workflow.

### Iterate and Refine
If a ticket is too large or unclear, ask the product manager to split it or clarify.

### Parallel Development
For larger projects, assign different tickets to multiple developer instances to work in parallel.

### Keep State in Git
The `.agents/` directory is version controlled. Commit after each phase for audit trail.

## Troubleshooting

### "No tickets available for development"
All ready tickets are in progress or blocked by dependencies. Check project status to see what's blocking progress.

### "Cannot transition to next phase"
Current phase validation failed. Check error message for missing requirements.

### "Ticket failed QA"
Review QA report in ticket file for specific issues. Developer agent can fix and resubmit.

### "Lost track of project state"
Run `"Show project status"` to see current phase and progress.

### "Want to change concept after starting development"
You can edit `.agents/concept.md` manually, but may need to revisit architecture and tickets if changes are significant.

## Advanced Usage

### Multiple Developers
Assign different tickets to separate developer instances:
```
"Assign TICKET-005 to software developer A"
"Assign TICKET-006 to software developer B"
```

They work independently, updating different tickets.

### Custom Workflows
You can manually edit `.agents/` files at any time:
- Refine concept after architect review
- Add tickets to backlog mid-development
- Skip phases if you have existing design docs

### Integration with Git
Commit after each phase:
```bash
git add .agents/
git commit -m "Complete architecture phase"
```

This creates an audit trail of decisions.

## Design Philosophy

**Guided Workflow**: You approve transitions between phases, ensuring alignment.

**Markdown-Based State**: All state in version-controlled markdown files (no databases or complex tools).

**Small Tickets**: 2-8 hour tickets minimize risk and enable steady progress.

**Quality Gates**: QA validation ensures each ticket meets standards before marking complete.

**Traceability**: Every decision documented (concept, architecture, ADRs, tickets).

**Standalone**: Works offline, no external dependencies or cloud services required.

## File Locations

**Agent Definitions**: `~/dotfiles/agents/agents/product-team/`
- product-designer.md
- software-architect.md
- product-manager.md
- software-developer.md
- qa-engineer.md

**Skill Definitions**: `~/dotfiles/agents/skills/project-team/`
- project-init/SKILL.md
- project-status/SKILL.md
- next-ticket/SKILL.md
- transition-phase/SKILL.md

**Documentation**: `~/dotfiles/agents/README-TEAM.md` (this file)

## Future Enhancements

Potential additions (not yet implemented):
- Cross-project memory (agents learn from past projects)
- Integration with GitHub Issues / Linear
- Automated git commits for each phase
- Progress visualizations and reports
- Sprint retrospectives and velocity tracking
- Template projects for common patterns

---

**Version**: 1.0
**Created**: 2026-02-20
**Status**: Production Ready

For questions or issues, refer to `~/dotfiles/agents/CLAUDE.md` for agent-specific guidance.
