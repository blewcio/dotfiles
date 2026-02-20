---
name: project-init
description: Initialize a new project for autonomous multi-agent product team workflow
compatibility: opencode
---

# Project Initialization Skill

Initialize the `.agents/` directory structure and template files for managing a software project with the autonomous product team (product designer, software architect, product manager, developers, QA).

## What This Skill Does

Creates a complete `.agents/` directory structure in the current project with:
- Template files for each workflow phase (concept, architecture, backlog, status)
- Ticket directory for individual work items
- Decisions directory for Architecture Decision Records (ADRs)
- Git initialization (if not already a git repo)
- Adds `.agents/` to version control

## Usage

Invoke this skill when starting a new software project that will use the product team workflow:

```
"Initialize agent project workflow"
"Set up project team"
"Create .agents directory"
```

## Directory Structure Created

```
.agents/
├── concept.md              # Product Designer output (template)
├── architecture.md         # Software Architect output (template)
├── backlog.md             # Product Manager: master ticket list (template)
├── status.md              # Current project status dashboard
├── tickets/               # Individual ticket files
│   └── .gitkeep
└── decisions/             # Architecture Decision Records (ADRs)
    └── .gitkeep
```

## Process

1. Check if `.agents/` already exists (prevent overwriting)
2. Create directory structure
3. Create template files with placeholder content
4. Initialize git if not already present
5. Add `.agents/` to git (stage but don't commit)
6. Display success message with next steps

## Template Files Content

### concept.md
Basic template showing structure for product designer to fill in.

### architecture.md
Basic template showing structure for software architect to fill in.

### backlog.md
Basic template showing structure for product manager to fill in.

### status.md
Dashboard showing current project phase and progress.

## Error Handling

- If `.agents/` exists: ask user if they want to overwrite or abort
- If not in a project directory: ask user to confirm location
- If git init fails: continue anyway (git is optional)

## Next Steps After Running

The skill will guide the user to:
1. Start concept phase with product designer agent
2. Or manually edit `.agents/concept.md` if they already have a clear concept

---

## Implementation

When invoked:

1. **Check current directory**:
   - Verify we're in a suitable location (not home directory)
   - Check if `.agents/` already exists

2. **Create structure**:
   ```bash
   mkdir -p .agents/tickets .agents/decisions
   ```

3. **Create template files** (see templates below)

4. **Git setup**:
   ```bash
   git init 2>/dev/null || true
   git add .agents/
   ```

5. **Display guidance**:
   ```
   ✅ Project initialized with agent team workflow!

   Next steps:
   1. Start the concept phase:
      "I want to discuss my project idea with the product designer"

   2. Or manually edit .agents/concept.md if you have a clear concept

   Project structure:
   - .agents/concept.md - Product vision and user stories
   - .agents/architecture.md - Technical design
   - .agents/backlog.md - Ticket list
   - .agents/status.md - Project dashboard
   ```

## Templates

### .agents/concept.md

```markdown
# Project Concept: [Project Name]

> **Status**: 🔄 In Progress
> **Phase**: Concept
> **Last Updated**: [Date]

This file will be filled in by the product-designer agent through discovery conversations.

To start the concept phase, say:
"I want to discuss my project idea with the product designer"

---

## Vision
[To be filled in]

## Problem Statement
[To be filled in]

## User Stories
[To be filled in]

## Success Criteria
[To be filled in]

## Constraints
[To be filled in]

## Out of Scope (v1)
[To be filled in]
```

### .agents/architecture.md

```markdown
# Architecture: [Project Name]

> **Status**: ⏳ Pending (waiting for concept approval)
> **Phase**: Architecture
> **Last Updated**: [Date]

This file will be filled in by the software-architect agent after concept is approved.

---

## Tech Stack Decision
[To be filled in]

## System Components
[To be filled in]

## Data Model
[To be filled in]

## API/Interface Design
[To be filled in]

## Non-Functional Requirements
[To be filled in]

## Architecture Decision Records
See `.agents/decisions/` for detailed ADRs.
```

### .agents/backlog.md

```markdown
# Project Backlog: [Project Name]

> **Status**: ⏳ Pending (waiting for architecture approval)
> **Phase**: Planning
> **Last Updated**: [Date]

This file will be filled in by the product-manager agent after architecture is approved.

---

## Sprint 1: Foundation
[To be filled in]

## Ticket Dependencies
[To be filled in]
```

### .agents/status.md

```markdown
# Project Status Dashboard

**Last Updated**: [Current Date and Time]

---

## Current Phase

🔄 **CONCEPT** - Product design and requirements gathering

---

## Phase Progress

| Phase         | Status      | Document           |
|---------------|-------------|--------------------|
| Concept       | 🔄 In Progress | concept.md      |
| Architecture  | ⏳ Pending     | architecture.md |
| Planning      | ⏳ Pending     | backlog.md      |
| Development   | ⏳ Pending     | tickets/*.md    |
| Delivery      | ⏳ Pending     | -               |

---

## Tickets Summary

**Total**: 0
**Ready**: 0
**In Progress**: 0
**Dev Complete**: 0
**QA Pass**: 0
**Blocked**: 0

---

## Next Actions

1. Start product discovery:
   - "I want to discuss my project idea with the product designer"
2. Once concept is approved:
   - Transition to architecture phase
3. Track progress:
   - Use "Show project status" to see updates

---

## Quick Commands

- `"Show project status"` - Refresh this dashboard
- `"Move to [phase] phase"` - Transition between phases (requires approval)
- `"Get next ticket"` - Find next available development task
```

### .agents/tickets/.gitkeep

```
# This directory will contain individual ticket files (TICKET-001.md, TICKET-002.md, etc.)
```

### .agents/decisions/.gitkeep

```
# This directory will contain Architecture Decision Records (ADRs)
# Format: NNN-title.md (e.g., 001-database-choice.md)
```

---

**Compatibility**: Works with both Claude Code and OpenCode (opencode compatible).
