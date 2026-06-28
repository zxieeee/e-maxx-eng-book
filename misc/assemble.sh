#!/bin/bash

# Move to root
cd "$(dirname "$0")/.."

layout="${1:-oneside}"
case "$layout" in
  oneside)
    classopts="12pt,a4paper,oneside"
    ;;
  twoside|print)
    classopts="12pt,a4paper,twoside"
    ;;
  -h|--help)
    cat <<'EOF' >&2
Usage: $0 [oneside|twoside]

Arguments:
  oneside   Generate a normal single-sided PDF layout (default)
  twoside   Generate a two-sided print-friendly PDF layout
EOF
    exit 0
    ;;
  *)
    echo "Unknown layout: $layout" >&2
    echo "Usage: $0 [oneside|twoside]" >&2
    exit 1
    ;;
esac

TEMPFILE=$(mktemp) && (
python3 misc/parse_navigation.py e-maxx-eng/src/navigation.md > "$TEMPFILE"

COMMIT_HASH="$(git rev-parse --short HEAD:e-maxx-eng)"

sed '/^% CONTENT GOES HERE$/r'"${TEMPFILE}" <(
  CLASSOPTS="${classopts}" COMMIT_HASH="${COMMIT_HASH}" python3 -c '
import os
from pathlib import Path
text = Path("misc/template.tex").read_text().splitlines()
if text and text[0].startswith("\\documentclass["):
    text[0] = f"\\documentclass[{os.environ["CLASSOPTS"]}]{{book}}"
text = "\n".join(text)
text = text.replace("LASTCOMMIT", os.environ["COMMIT_HASH"])
print(text, end="")
'
)

rm "$TEMPFILE"
)
