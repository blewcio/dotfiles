---
name: vault-audit-consistency
description: Knowledge-Curator-style consistency audit of a PARA/knowledge-base style project vault — checks naming conventions, YAML frontmatter validity, cross-reference/link integrity, and file placement, then proposes fixes. Use when asked to "check the structure", "audit consistency", "check if the vault is still consistent", or before a major restructure.
compatibility: opencode
---

# Vault Consistency Audit — Knowledge-Curator pass

Audits a project vault for drift that accumulates naturally as files get
added over time: naming inconsistency, broken cross-references, invalid or
missing frontmatter, misplaced files, and duplicated source-of-truth facts.

## Non-goals

Don't rename/move/delete anything without listing the findings and getting
explicit approval first — this is an audit-and-propose skill, not an
auto-fix skill, unless the user has already pre-approved batch fixes for
this exact kind of issue in this session.

## Step 1 — Establish the vault's own conventions

Don't assume a convention — derive it from the vault itself. Read the root
`AGENTS.md` and/or `MOC.md` if present; they may already document naming
rules, frontmatter schema, and source-of-truth splits. If absent, infer
conventions from the majority pattern within each folder (e.g. "this folder
is 90% `Title-Case-Hyphenated.md`, these 2 files are outliers").

## Step 2 — Check each dimension

1. **Naming**: flag files that don't match their folder's dominant
   convention.
2. **Frontmatter**: flag files missing frontmatter entirely, missing
   required baseline keys (commonly `type`/`status`/`updated`), or with
   structurally invalid YAML (e.g. content accidentally inserted inside the
   `---` delimiters, as can happen with plugin-specific frontmatter like
   Obsidian's `kanban-plugin: board`).
3. **Cross-references**: grep for markdown links and bare filename mentions;
   flag any that point to a renamed/moved/deleted file.
4. **Placement**: flag files that look like they belong in a different
   folder than the one they're in (based on content vs. folder purpose, not
   just filename).
5. **Source-of-truth duplication**: flag when two files both assert the
   same fact (a date, an owner, a status) without one clearly deferring to
   the other — this is where drift bugs hide.
6. **Junk/hygiene**: flag editor backup files (`.bak`, `~`), and duplicate
   attachments (compare by checksum, not just filename, before flagging as
   "duplicate").

## Step 3 — Report and propose

Present findings grouped by dimension, each with the specific fix proposed
(e.g. "rename X → Y, update N references in files A, B, C"). Wait for
explicit approval before executing, unless the user has already said
something equivalent to "fix all" for this exact audit.

## Step 4 — Execute and verify

After approval, execute renames/edits, then re-grep to confirm no dangling
references remain, and re-validate any frontmatter you touched.
