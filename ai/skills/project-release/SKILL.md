---
name: project-release
description: Cut a semantic-versioned release of an app — pick the version bump, date the changelog entry, sync APP_VERSION, merge to main and tag. Also covers changelog format when setting one up.
compatibility: opencode
---

## What I do

1. Read the "Unreleased" entry in `public/changelog.html` and propose the bump (semver MAJOR.MINOR.PATCH):
   - **major**: breaking change (removed/renamed behaviour, incompatible data or config)
   - **minor**: new feature
   - **patch**: fix only
2. Rename "Unreleased" to `V1.2.0 (YYYY-MM-DD)` (today's date) and add a fresh empty "Unreleased" entry above it
3. Set the single version constant (e.g. `APP_VERSION`) to the same version
4. Present the release commit (scope + description) for approval, then commit on the feature branch
5. Rebase the branch onto main and merge locally — no pull requests
6. Ask before tagging; tag the merge commit on main as `v1.2.0` (lowercase `v`)

## When to use me

Use when Bob says "release", "cut a version", "bump the version" or "tag a release", or when setting up a changelog in a new app.

## Changelog format

- Location: `public/changelog.html`, user-facing language (what changed for the user, not internal refactors)
- Newest entry first, one entry per version: `V1.2.0 (YYYY-MM-DD)`
- Between releases, collect changes under "Unreleased"
- If the repo has no changelog or version constant yet, propose creating both before releasing

## Notes

- Never tag or push tags without explicit approval
- Changelog heading, `APP_VERSION` and tag must all show the same version
- If "Unreleased" is empty, say so and ask whether a release is still wanted
