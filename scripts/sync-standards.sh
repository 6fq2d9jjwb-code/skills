#!/usr/bin/env bash
# Single source of truth for the animation standards.
#
#   shared/STANDARDS.md          the source. Reusable blocks are wrapped in
#                                <!-- section: NAME --> ... <!-- /section: NAME -->
#   skills/<skill>/STANDARDS.md  whole-file copies of the source (COPIES below), so
#                                every skill stays self-contained when installed alone
#   <!-- include: NAME --> ... <!-- /include: NAME -->
#                                in any skills/**/*.md: the lines between the markers
#                                are replaced by that section's content
#
# Usage:  scripts/sync-standards.sh          rewrite copies and included blocks
#         scripts/sync-standards.sh --check  exit 1 if anything is out of date (CI)
set -euo pipefail
cd "$(dirname "$0")/.."
SRC=shared/STANDARDS.md
COPIES=(animate review-animations improve-animations find-animation-opportunities emil-design-eng prototype)
mode=${1:-sync}
rc=0

splice() {  # $1 = target file; prints the file with every include block refreshed
  awk -v src="$SRC" '
    BEGIN {
      while ((getline line < src) > 0) {
        if (line ~ /^<!-- section: [A-Za-z0-9_-]+ -->$/) {
          name = line; sub(/^<!-- section: /, "", name); sub(/ -->$/, "", name)
          cur = name; body[cur] = ""; known[cur] = 1
        } else if (line ~ /^<!-- \/section: [A-Za-z0-9_-]+ -->$/) {
          cur = ""
        } else if (cur != "") {
          body[cur] = body[cur] line "\n"
        }
      }
    }
    /^<!-- include: [A-Za-z0-9_-]+ -->$/ {
      print; name = $0; sub(/^<!-- include: /, "", name); sub(/ -->$/, "", name)
      if (!(name in known)) { print "unknown section: " name > "/dev/stderr"; exit 3 }
      printf "%s", body[name]; skipping = 1; next
    }
    /^<!-- \/include: [A-Za-z0-9_-]+ -->$/ { skipping = 0; print; next }
    skipping { next }
    { print }
  ' "$1"
}

while IFS= read -r t; do
  tmp=$(mktemp)
  splice "$t" > "$tmp"
  if [ "$mode" = "--check" ]; then
    cmp -s "$tmp" "$t" || { echo "DRIFT (include block): $t"; rc=1; }
  else
    cmp -s "$tmp" "$t" || { cp "$tmp" "$t"; echo "spliced  $t"; }
  fi
  rm -f "$tmp"
done < <(find skills -name '*.md' -exec grep -l -- '<!-- include: ' {} + | sort)

for s in "${COPIES[@]}"; do
  dst="skills/$s/STANDARDS.md"
  if [ "$mode" = "--check" ]; then
    cmp -s "$SRC" "$dst" 2>/dev/null || { echo "DRIFT (copy): $dst"; rc=1; }
  else
    cmp -s "$SRC" "$dst" 2>/dev/null || { cp "$SRC" "$dst"; echo "copied   $dst"; }
  fi
done

if [ "$mode" = "--check" ] && [ "$rc" = 0 ]; then
  echo "standards: every copy and included block matches $SRC"
fi
exit "$rc"
