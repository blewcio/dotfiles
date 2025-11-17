#!/usr/bin/env bash
# ------------------------------------------------------------
# Move every video in the current directory to a folder
#   YEAR/MONTH   (e.g. 2016/08)
# based on the video’s internal creation_time tag.
# ------------------------------------------------------------
# Supported extensions – add/remove as needed
EXTENSIONS=(mp4 mov mkv avi webm 3gp MOV)

shopt -s nullglob   # make patterns expand to nothing if no match

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
# Main loop – process every video file
# ------------------------------------------------------------
for ext in "${EXTENSIONS[@]}"; do
    for f in *."$ext"; do
        [ -e "$f" ] || continue   # skip if no file of this extension

        # ---- 1️⃣ Extract creation_time from ffmpeg output ----
        ct=$(ffmpeg -i "$f" 2>&1 \
              | grep -i 'creation_time' \
              | head -n1 \
              | sed -E 's/.*creation_time[[:space:]]*:[[:space:]]*([^[:space:]]+).*/\1/')

        if [[ -z "$ct" ]]; then
            echo "⚠️  No creation_time in \"$f\" – leaving in place"
            continue
        fi

        # ---- 2️⃣ Convert to YEAR/MONTH -----------------------
        target_dir=$(iso_to_year_month "$ct")
        if [[ -z "$target_dir" ]]; then
            echo "❌  Could not parse timestamp \"$ct\" for \"$f\""
            continue
        fi

        # ---- 3️⃣ Create the directory (if it does not exist) --
        # mkdir -p "$target_dir"

        # ---- 4️⃣ Move the file -------------------------------
        # mv -i -- "$f" "$target_dir/"
        echo "✅  Moved \"$f\" → \"$target_dir/\""
    done
done
