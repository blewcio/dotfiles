# Obsidian vault template

`vault-template/` holds Bob's standard Obsidian config. `plugins.txt` lists
the community plugins (GitHub repo per plugin). Plugin code itself is **not
stored in git**; it is downloaded from GitHub releases into a local cache.

## Scripts (in `bin/`)

- `obsidian-new-vault <path>` — create a fresh vault from the template.
- `obsidian-sync-vault <path>` — merge template updates into an *existing*
  vault. Template values win for keys it defines, vault-only keys and each
  plugin's own `data.json` are kept, and the old config is backed up first.
- `obsidian-fetch-plugins [--update]` — fill / refresh the plugin cache
  (`~/.cache/obsidian-plugins`, override with `OBSIDIAN_PLUGIN_CACHE`).
  Both scripts above call it automatically for plugins missing from the cache.

## Plugins

`plugins.txt` format: `<plugin-id> <owner/repo> [pinned-version]`. Without a
version the newest GitHub release is used. Pin one only where "latest" is
unwanted (calendar: its newest release is a 2.0 beta).

Cached plugins are reused as-is, so syncing a vault never changes plugin
code by itself. To update, run `obsidian-fetch-plugins --update` (prints
`old -> new` per plugin), then `obsidian-sync-vault` on each vault. Needs
`curl` and `jq`.

## Copy vs. symlink

- **Copied** — `app.json`, `core-plugins.json`, `community-plugins.json`,
  `appearance.json`, `daily-notes.json`, `hotkeys.json`, and the plugin
  folders. Obsidian and plugins rewrite these at runtime without checking if
  they changed on disk, so a symlink shared across vaults would get silently
  clobbered whenever two vaults are open.
- **Symlinked** — `.obsidian.vimrc`, and `.obsidian/snippets/` if present.
  These are only ever hand-edited in the template, never written by
  Obsidian itself, so an edit to the template applies live to every vault.

Obsidian has no native "shared config across vaults" feature — its
"Override config folder" setting only renames the config folder within a
single vault. This copy/symlink split is the standard community workaround.
