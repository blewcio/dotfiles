#!/usr/bin/env bash
# ------------------------------------------------------------
# Move video files to YEAR/MONTH directories based on
# the video's internal creation_time tag.
#
#   ./vid_sort_by_date.sh *.mp4              # Sort videos
#   ./vid_sort_by_date.sh -n *.avi           # Dry-run (no changes)
# ------------------------------------------------------------

# ---------- 1️⃣  Parse arguments ----------
DRY_RUN=false
FILES=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [-n] FILE..."
            echo "  -n, --dry-run    Show what would be moved without making changes"
            echo "  FILE...          One or more video files to process"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            FILES+=("$1")
            shift
            ;;
    esac
done

# Check if files were provided
if [[ ${#FILES[@]} -eq 0 ]]; then
    echo "Error: No files specified" >&2
    echo "Usage: $0 [-n] FILE..." >&2
    echo "Example: $0 *.mp4" >&2
    echo "         $0 -n *.avi" >&2
    exit 1
fi

# ------------------------------------------------------------
# Portable conversion: ISO‑8601 → YYYY and MM
# ------------------------------------------------------------
iso_to_year_month() {
    local iso="${1%Z}"               # strip trailing Z (UTC marker)

    # ---------- GNU date (most Debian installs) ----------
    if date --version >/dev/null 2>&1; then
        # -u = UTC, -d = parse string
        year=$(date -u -d "$iso" +"%Y")
        month=$(date -u -d "$iso" +"%m")
        printf '%s/%s' "$year" "$month"
        return
    fi

    # ---------- BSD / BusyBox date ----------
    # The format string must match the input exactly.
    year=$(date -u -j -f "%Y-%m-%dT%H:%M:%S.%3N" "$iso" +"%Y" 2>/dev/null) && \
    month=$(date -u -j -f "%Y-%m-%dT%H:%M:%S.%3N" "$iso" +"%m" 2>/dev/null) && \
    { printf '%s/%s' "$year" "$month"; return; }

    # ---------- Fallback to Python ----------
    python3 - <<PY
import datetime, sys
s = "$iso"
dt = datetime.datetime.fromisoformat(s)
print(f"{dt.year:04d}/{dt.month:02d}")
PY
}

# ------------------------------------------------------------
# Main loop – process specified video files
# ------------------------------------------------------------
for f in "${FILES[@]}"; do
    if [[ ! -e "$f" ]]; then
        echo "⚠️  File not found: \"$f\" – skipping"
        continue
    fi
    if [[ ! -f "$f" ]]; then
        echo "⚠️  Not a regular file: \"$f\" – skipping"
        continue
    fi

    # ---- 2️⃣ Extract creation_time from ffmpeg output ----
    ct=$(ffmpeg -i "$f" 2>&1 \
          | grep -i 'creation_time' \
          | head -n1 \
          | sed -E 's/.*creation_time[[:space:]]*:[[:space:]]*([^[:space:]]+).*/\1/')

    if [[ -z "$ct" ]]; then
        echo "⚠️  No creation_time in \"$f\" – skipping"
        continue
    fi

    # ---- 3️⃣ Convert to YEAR/MONTH -----------------------
    target_dir=$(iso_to_year_month "$ct")
    if [[ -z "$target_dir" ]]; then
        echo "❌  Could not parse timestamp \"$ct\" for \"$f\""
        continue
    fi

    # ---- 4️⃣ Move the file -------------------------------
    if [[ "$DRY_RUN" == true ]]; then
        echo "🔍  Would move: \"$f\" → \"$target_dir/\""
    else
        mkdir -p "$target_dir"
        mv -i -- "$f" "$target_dir/"
        echo "✅  \"$f\" → \"$target_dir/\""
    fi
done
