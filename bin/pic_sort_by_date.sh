#!/usr/bin/env bash
# ------------------------------------------------------------
# Sort pictures into YEAR/MONTH directories.
#
#   ./sort_pics.sh               # → EXIF mode (default)
#   ./sort_pics.sh --moddate    # → use file modification time (mtime)
# ------------------------------------------------------------

# ---------- 1️⃣  Configuration ----------
EXTENSIONS=(jpg jpeg png tif tiff heic avif raw cr2 cr3 nef orf 3gp xcf)

# Choose the source of the date:
#   * "exif" – use EXIF tags (default)
#   * "mod"  – use file modification time (mtime)
DATE_SOURCE="exif"

# Parse optional flag
while [[ $# -gt 0 ]]; do
    case "$1" in
        --moddate|--mtime) DATE_SOURCE="mod" ;;
        --exifdate|--exif) DATE_SOURCE="exif" ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

shopt -s nullglob   # make patterns expand to nothing if no match

# ---------- 2️⃣  Helper: get YEAR/MONTH ----------
get_year_month() {
    local file="$1"

    if [[ "$DATE_SOURCE" == "mod" ]]; then
        # ---------- file modification time (mtime) ----------
        if date --version >/dev/null 2>&1; then          # GNU date
            date -r "$file" +"%Y/%m"
            return
        fi
        # BSD date – obtain epoch with stat first
        if epoch=$(stat -c "%Y" "$file" 2>/dev/null); then
            date -r "$epoch" +"%Y/%m" && return
        fi
        # Fallback to Python
        python3 - <<PY
import os, datetime, sys
print(datetime.datetime.fromtimestamp(os.path.getmtime("$file")).strftime("%Y/%m"))
PY
        return
    fi

    # ---------- EXIF mode ----------
    # exiftool returns the first non‑empty tag among the list we give it.
    # The tags are queried in the exact priority we need.
    # -DateTimeOriginal  (capture time)
    # -CreateDate        (fallback capture time)
    # -ModifyDate        (EXIF edit time – still an EXIF tag)
    # The -d option formats the output as "YYYY/MM".
    local exif_dir
    exif_dir=$(exiftool -s -s -s -d "%Y/%m" \
                -DateTimeOriginal -CreateDate -ModifyDate \
                "$file" 2>/dev/null | head -n1)

    # If none of the three EXIF tags exist, return empty → caller will skip.
    echo "$exif_dir"
}

# ---------- 3️⃣  Main processing ----------
for ext in "${EXTENSIONS[@]}"; do
    for f in *."$ext" *."${ext^^}"; do   # also match upper‑case extensions
        [ -e "$f" ] || continue

        target_dir=$(get_year_month "$f")
        if [[ -z "$target_dir" ]]; then
            echo "⚠️  No suitable EXIF timestamp for \"$f\" – skipping"
            continue
        fi

        mkdir -p "$target_dir"
        mv -i -- "$f" "$target_dir/"
        echo "✅  \"$f\" → \"$target_dir/\""
    done
done
