#!/usr/bin/env bash
# Repo checks, run by CI and before every commit:
#   1. shared standards are in sync (scripts/sync-standards.sh --check)
#   2. every SKILL.md has frontmatter whose name matches its folder and a real description
#   3. every relative .md link resolves
#   4. no SKILL.md is over 500 lines (progressive disclosure: long material goes in a reference file)
set -euo pipefail
cd "$(dirname "$0")/.."
rc=0

bash scripts/sync-standards.sh --check || rc=1

for f in skills/*/SKILL.md; do
  name=$(basename "$(dirname "$f")")
  [ "$(head -1 "$f")" = "---" ] || { echo "no frontmatter: $f"; rc=1; }
  grep -q "^name: $name\$" "$f" || { echo "frontmatter name is not '$name': $f"; rc=1; }
  grep -q -E '^description: .{40,}' "$f" || { echo "description missing or too short: $f"; rc=1; }
  lines=$(wc -l < "$f")
  [ "$lines" -le 500 ] || { echo "over 500 lines ($lines): $f"; rc=1; }
done

while IFS=: read -r f link; do
  [ -f "$(dirname "$f")/$link" ] || { echo "broken link: $f -> $link"; rc=1; }
done < <(grep -o -H -E '\]\([A-Za-z0-9_./-]+\.md\)' skills/*/*.md | sed -E 's/\]\(([^)]*)\)$/\1/')

[ "$rc" = 0 ] && echo "check: all good"
exit "$rc"
