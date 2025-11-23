# Keybindings Analysis - Inconsistencies Found

## Critical Inconsistencies Between Cheat Sheet and Actual Config

### Custom Keybindings (Modified from defaults)

| Key | Cheat Sheet Says | Actual Config | File:Line |
|-----|-----------------|---------------|-----------|
| **A-h** | `cd $HOME` | **UNBOUND** (was `backward-word`) | inputrc.sh:21,61 (commented) |
| **A-l** | `la` | **UNBOUND** (was `forward-word`) | inputrc.sh:22,62 (commented) |
| **A-a** | `cd -` | **NOT CONFIGURED** | - |
| **A-.** | `cd ..` | ✓ CORRECT `cd ..` | inputrc.sh:25,57 |
| **A-c** | `fzf based cd` | ✓ CORRECT (from fzf) | - |
| **A-i** | `fzf search of a file` | ✓ CORRECT (from fzf) | - |
| **C-k** | `(now a-k) Delete forward...` | ✓ CORRECT (rebound to A-k) | inputrc.sh:29,66 |
| **C-r** | `Research command history` | `fzf-history-widget` (in zsh with autocomplete) | shellrc.sh:130 |

### Missing from Cheat Sheet (but configured)

**ZSH Text Selection (Shift+Arrow keys):**
- `Shift+Left` - Select backward by character (shellrc.sh:134)
- `Shift+Right` - Select forward by character (shellrc.sh:135)
- `Shift+Up` - Select entire line (shellrc.sh:136)
- `Shift+Down` - Deselect region (shellrc.sh:137)
- `Shift+Alt+Left` - Select backward by word (shellrc.sh:138)
- `Shift+Alt+Right` - Select forward by word (shellrc.sh:139)

**FZF Keybindings (zsh):**
- `C-t` - fzf file widget (shellrc.sh:156)
- Tab completion with menu-complete (shellrc.sh:127)

**Other Custom:**
- `A-*` - Execute `ls` (inputrc.sh:23,55)
- German keyboard character remappings (ß, ü, ö, ä, etc.)

### Standard Terminal Keybindings (Verified Correct)

✓ All standard readline/emacs keybindings in your cheat sheet are correct:
- Navigation: C-a, C-e, C-f, C-b, A-f, A-b
- Deletion: C-u, C-d, C-h, C-w, A-d
- Editing: C-t, A-t, C-_
- Clipboard: C-y, A-y
- Process: C-c, C-z, C-d, C-l
- History: C-p, C-n, C-g
- Shortcuts: !!, !$, !^, A-.

## Summary

**Major Issues:**
1. **A-h** and **A-l** have been unbound (previously were word navigation, not filesystem ops as documented)
2. **A-a** is not actually configured anywhere in your dotfiles
3. Missing documentation for Shift+Arrow text selection (zsh only)
4. C-r behavior differs slightly in zsh with autocomplete plugin

**Recommendation:**
Update keys_terminal.txt to reflect actual configuration, especially the A-h and A-l bindings.
