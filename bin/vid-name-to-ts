#!/usr/bin/env bash
shopt -s nullglob

format_ts() {
    local iso="${1%Z}"
    if date --version >/dev/null 2>&1; then
        date -u -d "$iso" +"%Y%m%d%H%M%S%3N"; return
    fi
    date -u -j -f "%Y-%m-%dT%H:%M:%S.%3N" "$iso" +"%Y%m%d%H%M%S%3N" 2>/dev/null && return
    python3 - <<PY
import datetime,sys
s = "$iso"
dt = datetime.datetime.fromisoformat(s)
print(dt.strftime('%Y%m%d%H%M%S') + f"{int(dt.microsecond/1000):03d}")
PY
}

for f in *.mp4 *.mov *.mkv *.avi *.webm *.MOV; do
    [ -e "$f" ] || continue
    ct=$(ffmpeg -i "$f" 2>&1 | grep -i 'creation_time' | head -n1 |
         sed -E 's/.*creation_time[[:space:]]*:[[:space:]]*([^[:space:]]+).*/\1/')
    [[ -z $ct ]] && { echo "⚠️ $f → no tag"; continue; }
    ts=$(format_ts "$ct")
    ext="${f##*.}"
    new="${ts}.${ext}"
    i=1; while [[ -e "$new" ]]; do new="${ts}_$i.${ext}"; ((i++)); done
    # mv -i -- "$f" "$new"
    echo "✅ $f → $new"
done
