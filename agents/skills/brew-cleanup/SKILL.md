---
name: brew-cleanup
description: Audit macOS Brewfile against installed packages, flag orphans, missing entries, and stale comments
compatibility: opencode
---

## What I do

1. Read `~/dotfiles/mac/Brewfile` to get the declared package list
2. Run `brew bundle check --file=~/dotfiles/mac/Brewfile` to find packages declared but not installed
3. Run `brew leaves` and `brew list --cask` to find installed packages not declared in Brewfile (orphans)
4. Cross-reference and report:
   - **Missing**: declared in Brewfile but not installed
   - **Orphans**: installed but not in Brewfile
   - **Commented-out candidates**: packages commented with `#` that are actually installed (may warrant uncommenting or removing)
5. Suggest concrete edits to Brewfile (add, remove, or uncomment lines)
6. Ask before making any changes

## When to use me

Use this after installing or removing packages manually, or periodically to keep the Brewfile in sync with reality.
Invoke me with: "run brew-cleanup" or "audit my Brewfile".

## Notes

- Never remove packages from the system automatically — only edit the Brewfile
- Preserve section comments and formatting when suggesting edits
- Treat `mas` (App Store) entries separately — they require manual verification
