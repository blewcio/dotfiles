
#!/usr/bin/env bash
# ------------------------------------------------------------
# Rename video files to:
#   YYYYMMDDHHMMSSmmm[_CUSTOM_TAG].<extension>
# using the embedded creation_time tag.
# ------------------------------------------------------------
# Usage:
#   ./vid_name_to_ts_tag.sh *.mp4                    # → 20231116123045123.mp4
#   ./vid_name_to_ts_tag.sh -t MyEvent video.mp4    # → 20231116123045123_MyEvent.mp4
#   ./vid_name_to_ts_tag.sh -t MyEvent *.avi        # Process multiple files with tag
#   ./vid_name_to_ts_tag.sh -n *.mp4                # Dry-run: show what would be renamed
# ------------------------------------------------------------

# ---- 1️⃣  Parse arguments -----------------------------------------
CUSTOM_TAG=""
DRY_RUN=false
FILES=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--tag)
            if [[ -n "$2" && "$2" != -* ]]; then
                CUSTOM_TAG="$2"
                shift 2
            else
                echo "Error: -t requires a tag argument" >&2
                exit 1
            fi
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [-t TAG] [-n] FILE..."
            echo "  -t, --tag TAG    Optional custom tag to append to filename"
            echo "  -n, --dry-run    Show what would be renamed without making changes"
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
    echo "Usage: $0 [-t TAG] FILE..." >&2
    echo "Example: $0 *.mp4" >&2
    echo "         $0 -t MyEvent *.avi" >&2
    exit 1
fi

# Replace spaces with underscores and strip leading/trailing underscores
CUSTOM_TAG="${CUSTOM_TAG// /_}"
CUSTOM_TAG="${CUSTOM_TAG##_}"
CUSTOM_TAG="${CUSTOM_TAG%_}"

# If a tag is present, prepend an underscore for the final name
TAG_SUFFIX=""
[[ -n "$CUSTOM_TAG" ]] && TAG_SUFFIX="_${CUSTOM_TAG}"

# ------------------------------------------------------------
# Helper: convert ISO‑8601 → YYYYMMDDHHMMSSmmm (portable)
# ------------------------------------------------------------
format_ts() {
    local iso="${1%Z}"                     # drop trailing Z (UTC marker)

    # GNU date (most Debian systems)
    if date --version >/dev/null 2>&1; then
        date -u -d "$iso" +"%Y%m%d%H%M%S%3N"
        return
    fi

    # BSD / BusyBox date
    date -u -j -f "%Y-%m-%dT%H:%M:%S.%3N" "$iso" +"%Y%m%d%H%M%S%3N" 2>/dev/null && return

    # Fallback to Python (always present on Debian)
    python3 - <<PY
import datetime, sys
s = "$iso"
dt = datetime.datetime.fromisoformat(s)
print(dt.strftime('%Y%m%d%H%M%S') + f"{int(dt.microsecond/1000):03d}")
PY
}

# ------------------------------------------------------------
# Main loop – process specified files
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

    # ---- 2️⃣ Extract creation_time from ffmpeg output -------------
    ct=$(ffmpeg -i "$f" 2>&1 \
          | grep -i 'creation_time' \
          | head -n1 \
          | sed -E 's/.*creation_time[[:space:]]*:[[:space:]]*([^[:space:]]+).*/\1/')

    if [[ -z "$ct" ]]; then
        echo "⚠️  No creation_time in \"$f\" – skipping"
        continue
    fi

    # ---- 3️⃣ Convert to required timestamp ------------------------
    ts=$(format_ts "$ct")
    if [[ -z "$ts" ]]; then
        echo "❌  Failed to parse timestamp \"$ct\" for \"$f\""
        continue
    fi

    # ---- 4️⃣ Build new filename ------------------------------------
    ext="${f##*.}"
    base="${ts}${TAG_SUFFIX}"          # e.g. 20231116123045123_MyEvent
    new="${base}.${ext}"

    # ---- 5️⃣ Avoid overwriting an existing file --------------------
    i=1
    while [[ -e "$new" ]]; do
        new="${base}_$i.${ext}"
        ((i++))
    done

    # ---- 6️⃣ Rename ------------------------------------------------
    if [[ "$DRY_RUN" == true ]]; then
        echo "🔍  Would rename: \"$f\" → \"$new\""
    else
        mv -i -- "$f" "$new"
        echo "✅  \"$f\" → \"$new\""
    fi
done
