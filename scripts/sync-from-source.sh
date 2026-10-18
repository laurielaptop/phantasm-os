#!/usr/bin/env bash
# Refresh the public documentation and the editor build from the two private
# source repositories, checked out as siblings of this one.
#
#   scripts/sync-from-source.sh [PHANTASM_REF]
#
# PHANTASM_REF is the Phantasm tag or commit the documents are taken from
# (default: the latest tag). The PDFs come from Phantasm's engine/build, so
# build them at that ref first (`make -C engine param-card manual`). The editor
# is rebuilt from phantasmeditor's checked-out tree.
#
# The private repositories link to files that are not published here, so the
# copies are rewritten. If upstream wording changes and a rewrite stops
# matching, the final check fails rather than publishing a dead link.

set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
phantasm="${PHANTASM_DIR:-$here/../phantasm}"
editor="${EDITOR_DIR:-$here/../phantasmeditor}"
ref="${1:-$(git -C "$phantasm" describe --tags --abbrev=0)}"

docs="$here/docs"
mkdir -p "$docs/diagrams" "$here/editor"

show() { git -C "$phantasm" show "$ref:$1"; }

# Quick-start guide and its diagrams.
show docs/QUICKSTART.md | perl -0pe '
  s/the printed parameter card \(`make -C engine param-card`\)/the [printed parameter card](phantasm-param-card.pdf)/;
  s/- The \*\*parameter card\*\*: `make -C engine param-card` writes\n\s*`engine\/build\/phantasm-param-card.pdf`, and `make -C engine manual` prints\n\s*the manual\./- The [parameter card](phantasm-param-card.pdf) (PDF), and the\n  [manual as a PDF](phantasm-manual.pdf) for printing./;
  s/\[The MIDI and SysEx protocol\]\(midi-protocol.md\)/[The MIDI implementation](MIDI-IMPLEMENTATION.md)/;
  s/- \[The architecture\]\(ARCHITECTURE.md\)[^\n]*\n[^\n]*\n//;
' > "$docs/QUICKSTART.md"
for svg in $(git -C "$phantasm" ls-tree --name-only "$ref" docs/diagrams/ | grep '/qs-'); do
  show "$svg" > "$docs/diagrams/$(basename "$svg")"
done

# Player's manual.
show docs/MANUAL.md | perl -0pe '
  s/read the quick-start guide, docs\/QUICKSTART.md, first/read the [quick-start guide](QUICKSTART.md) first/;
  s/The printed parameter card is/The printed [parameter card](phantasm-param-card.pdf) is/;
  s/phantasmeditor, a separate project, is the editor for it\./[Phantasm Editor](..\/README.md#phantasm-editor), a separate project, is the editor for it./;
  s/The protocol is in docs\/midi-protocol.md;/The protocol is in the [MIDI implementation](MIDI-IMPLEMENTATION.md);/;
' > "$docs/MANUAL.md"

# MIDI implementation: the protocol document from section 1 on. Its preamble
# is the internal version history.
{
  version="$(show docs/midi-protocol.md | sed -n '3s/^\*\*\(Protocol [0-9.]*, schema [0-9.]*\)\*\*.*/\1/p')"
  cat <<EOF
# Phantasm MIDI implementation

**$version**, Phantasm $ref.

Everything Phantasm receives and sends over MIDI: control changes, the SysEx
protocol used by [Phantasm Editor](../README.md#phantasm-editor), and the
Sample Dump receive for user waves. For a player's summary, see section 12 of
the [player's manual](MANUAL.md#12-midi); this document is for anyone writing
an editor, a librarian or a controller map. The one-page
[parameter card](phantasm-param-card.pdf) doubles as the CC chart.

EOF
  show docs/midi-protocol.md | sed -n '/^## 1\. Parameters/,$p' | perl -0pe '
    s/the printed card \(`make param-card`\)/the printed [parameter card](phantasm-param-card.pdf)/;
    s/The protocol, and every\nbyte layout, are in \[SDS.md\]\(SDS.md\); this section is what an editor needs\./This section is what\na sender needs; the byte layouts are those of the MIDI Sample Dump Standard./;
  '
} > "$docs/MIDI-IMPLEMENTATION.md"

# Printable PDFs.
cp "$phantasm/engine/build/phantasm-param-card.pdf" "$phantasm/engine/build/phantasm-manual.pdf" "$docs/"

# Editor: rebuild the single-file standalone page.
(cd "$editor" && npm run --silent build:standalone && npm run --silent test:standalone)
cp "$editor/dist/phantasm-editor.html" "$here/editor/phantasm-editor.html"

# Every relative link in the copies must resolve here.
fail=0
for md in "$docs"/*.md; do
  while IFS= read -r target; do
    path="${target%%#*}"
    [ -z "$path" ] && continue
    if [ ! -e "$(dirname "$md")/$path" ]; then
      echo "dead link in ${md#$here/}: $target" >&2; fail=1
    fi
  done < <(grep -oE '\]\([^)]+\)' "$md" | sed -E 's/^\]\((.*)\)$/\1/' | grep -vE '^(https?:|mailto:|#)')
done
if grep -nE 'make -C|make param-card' "$docs"/*.md >&2; then
  echo "a build command is still in the public docs (above)" >&2; fail=1
fi
[ "$fail" = 0 ] || exit 1

echo "synced docs from phantasm $ref ($(git -C "$phantasm" rev-parse --short "$ref"))"
echo "synced editor from phantasmeditor $(git -C "$editor" rev-parse --short HEAD)"
