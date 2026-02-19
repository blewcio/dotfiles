#!/usr/bin/env bash
# Links agent skills from tracked and private sources into ~/.claude/skills/
# Works for both OpenCode (~/.config/opencode/skills/) and Claude Code (~/.claude/skills/)
# Run manually to pick up new skills, or called automatically by deploy.sh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_TARGET="$HOME/.claude/skills"

# ── Replace whole-directory symlink with a real directory ──────────────────────
if [ -L "$SKILLS_TARGET" ]; then
    echo "Replacing directory symlink at $SKILLS_TARGET with a real directory..."
    rm "$SKILLS_TARGET"
fi
mkdir -p "$SKILLS_TARGET"

# ── Point ~/.config/opencode/skills/ at the same real directory ────────────────
# Use -n to avoid ln placing a new symlink *inside* an existing dir-symlink
mkdir -p "$HOME/.config/opencode"
ln -sfn "$SKILLS_TARGET" "$HOME/.config/opencode/skills"

# ── Symlink individual skills from a source directory ─────────────────────────
link_skills_from() {
    local source_dir="$1"
    local label="$2"

    [ -d "$source_dir" ] || return 0

    local found=0
    for skill_dir in "$source_dir"/*/; do
        [ -d "$skill_dir" ] || continue
        found=1

        local skill_name
        skill_name="$(basename "$skill_dir")"
        local target="$SKILLS_TARGET/$skill_name"

        if [ -L "$target" ]; then
            local current_link
            current_link="$(readlink "$target")"
            if [ "$current_link" = "$skill_dir" ]; then
                echo "  [ok]     $skill_name  ($label)"
                continue
            fi
            echo "  [update] $skill_name  ($label, was: $current_link)"
            rm "$target"
        elif [ -e "$target" ]; then
            echo "  [skip]   $skill_name  (real directory exists, not overwriting)"
            continue
        fi

        ln -sf "$skill_dir" "$target"
        echo "  [linked] $skill_name  ($label)"
    done

    [ "$found" -eq 0 ] && echo "  (no skills found in $source_dir)"
    return 0
}

echo "Linking skills into $SKILLS_TARGET ..."
echo ""
echo "Tracked skills (agents/skills/):"
link_skills_from "$DOTFILES_DIR/agents/skills" "tracked"

echo ""
echo "Private skills (private/skills/):"
link_skills_from "$DOTFILES_DIR/private/skills" "private"

echo ""
echo "Done. ~/.config/opencode/skills/ -> $SKILLS_TARGET"
