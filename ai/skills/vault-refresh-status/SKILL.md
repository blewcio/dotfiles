---
name: vault-refresh-status
description: Chief-of-Staff-style refresh of a project vault's status files after a session or meeting — updates the project brain snapshot, action tracker, risk register, and decision log from what actually changed. Use when asked to "refresh status", "do a Chief of Staff pass", "update the project brain", or at the end of a working session on a PARA-structured project vault.
compatibility: opencode
---

# Vault Status Refresh — Chief-of-Staff pass

Keeps a project vault's status-tracking files honest and current, without
duplicating facts across files or inventing status changes that didn't
actually happen this session.

## Non-goals

Don't invent new risks, decisions, or actions that weren't actually discussed
or decided. Don't re-state facts that live in one file inside another — link
instead. Don't mark anything "confirmed"/"done" unless the user or session
content actually said so.

## Step 0 — Find the vault's status files

Look for (in order of preference): a root brain/status file (commonly
`PROJECT_BRAIN.md` or similar single-entry-point file), then an action
tracker (e.g. `*/ACTION_ITEMS.md`), a risk register (e.g. `*/RISKS.md`), and
a decision log (e.g. `*/DECISION_LOG.md`). If a `MOC.md` (Map of Content) or
`AGENTS.md` exists at the vault root, read it first — it tells you where
these files actually live in this specific vault; don't assume folder names.

## Step 1 — Diff session vs. vault

Compare what was actually discussed/decided/changed in this session (or
since the status file's last `updated` date, if resuming later) against
what's currently recorded in each status file. Look specifically for:

- New or resolved action items
- New or closed risks
- New or superseded decisions
- Any change to the current-state snapshot (confirmed facts, open questions)

## Step 2 — Update, don't duplicate

For each file that needs a change:

- **Brain/status file**: update the snapshot section only where something
  actually changed — don't rewrite unaffected sections.
- **Action tracker**: append new rows with the next sequential ID matching
  the existing numbering scheme; update status of existing rows if resolved.
- **Risk register**: append new risks with the next ID; update
  likelihood/impact/mitigation only if genuinely reassessed, not routinely.
- **Decision log**: append using the file's own existing entry template if
  it has one — don't invent a different format.

If two files would end up stating the same fact (e.g. a date in both a
roadmap file and a status file), pick whichever is already established as
authoritative for that fact in this vault (check for an explicit
"source-of-truth" note) and have the other reference it instead of
restating it.

## Step 3 — Report

Summarize, per file, exactly what changed and why — and explicitly say when
a file needed **no** update, so the user knows the pass was thorough rather
than skipped.
