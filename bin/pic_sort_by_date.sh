#!/usr/bin/env bash
# ------------------------------------------------------------
# Sort pictures into YEAR/MONTH directories.
#
#   ./pic_sort_by_date.sh *.jpg              # → EXIF mode (default)
#   ./pic_sort_by_date.sh --moddate *.png    # → use file modification time
#   ./pic_sort_by_date.sh -n *.jpg           # → dry-run (no changes)
# ------------------------------------------------------------

# ---------- 1️⃣  Configuration ----------
# Choose the source of the date:
#   * "exif" – use EXIF tags (default)
#   * "mod"  – use file modification time (mtime)
DATE_SOURCE="exif"
DRY_RUN=false
FILES=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --moddate|--mtime)
            DATE_SOURCE="mod"
            shift
            ;;
        --exifdate|--exif)
            DATE_SOURCE="exif"
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS] FILE..."
            echo "  --moddate, --mtime    Use file modification time instead of EXIF"
            echo "  --exifdate, --exif    Use EXIF date (default)"
            echo "  -n, --dry-run         Show what would be moved without making changes"
            echo "  FILE...               One or more image files to process"
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
    echo "Usage: $0 [OPTIONS] FILE..." >&2
    echo "Example: $0 *.jpg" >&2
    echo "         $0 -n --moddate *.png" >&2
    exit 1
fi

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
for f in "${FILES[@]}"; do
    if [[ ! -e "$f" ]]; then
        echo "⚠️  File not found: \"$f\" – skipping"
        continue
    fi
    if [[ ! -f "$f" ]]; then
        echo "⚠️  Not a regular file: \"$f\" – skipping"
        continue
    fi

    target_dir=$(get_year_month "$f")
    if [[ -z "$target_dir" ]]; then
        echo "⚠️  No suitable timestamp for \"$f\" – skipping"
        continue
    fi

    if [[ "$DRY_RUN" == true ]]; then
        echo "🔍  Would move: \"$f\" → \"$target_dir/\""
    else
        mkdir -p "$target_dir"
        mv -i -- "$f" "$target_dir/"
        echo "✅  \"$f\" → \"$target_dir/\""
    fi
done
