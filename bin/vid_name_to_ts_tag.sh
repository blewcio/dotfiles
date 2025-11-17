
#!/usr/bin/env bash
# ------------------------------------------------------------
# Rename every video in the current folder to:
#   YYYYMMDDHHMMSSmmm[_CUSTOM_TAG].<extension>
# using the embedded creation_time tag.
# ------------------------------------------------------------
# Usage:
#   ./rename_by_creation.sh            # → 20231116123045123.mp4
#   ./rename_by_creation.sh MyEvent    # → 20231116123045123_MyEvent.mp4
# ------------------------------------------------------------

# ---- 1️⃣  Read optional custom tag ---------------------------------
CUSTOM_TAG="${1:-}"                     # first argument, or empty
# Replace spaces with underscores and strip leading/trailing underscores
CUSTOM_TAG="${CUSTOM_TAG// /_}"
CUSTOM_TAG="${CUSTOM_TAG##_}"
CUSTOM_TAG="${CUSTOM_TAG%_}"

# If a tag is present, prepend an underscore for the final name
TAG_SUFFIX=""
[[ -n "$CUSTOM_TAG" ]] && TAG_SUFFIX="_${CUSTOM_TAG}"

shopt -s nullglob   # make *.mp4 expand to nothing if no match

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
# Main loop – process common video extensions
# ------------------------------------------------------------
for f in *.mp4 *.mov *.mkv *.avi *.webm *.MOV *.MP4 *.3gp; do
    [ -e "$f" ] || continue                     # skip if pattern didn't match

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
    mv -i -- "$f" "$new"
    echo "✅  \"$f\" → \"$new\""
done
