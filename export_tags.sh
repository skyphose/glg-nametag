#!/bin/bash
# one 3mf per line of names.csv, into exports/.
# each line is Name,Title. the title is optional.
# usage:  ./export_tags.sh                    (reads names.csv, no logo)
#         LOGO=my-logo.svg ./export_tags.sh   (adds your logo, aspect worked out for you)
#         ./export_tags.sh staff.csv
# extra openscad options pass through:
#         EXTRA='-D part="Raised only"' ./export_tags.sh

CSV="${1:-names.csv}"
OPENSCAD="${OPENSCAD:-/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD}"
command -v "$OPENSCAD" >/dev/null 2>&1 || OPENSCAD=openscad
cd "$(dirname "$0")" || exit 1
mkdir -p exports

LOGO_ARGS=""
if [ -n "$LOGO" ]; then
  ASPECT="$(python3 tools/svg_aspect.py "$LOGO")" || exit 1
  LOGO_ARGS="-D 'logo_file=\"$LOGO\"' -D logo_aspect=$ASPECT"
  echo "logo $LOGO, aspect $ASPECT"
fi

while IFS=, read -r NAME TITLE || [ -n "$NAME" ]; do
  NAME="$(echo "$NAME" | xargs)"; TITLE="$(echo "$TITLE" | xargs)"
  [ -z "$NAME" ] && continue
  [[ "$NAME" == \#* ]] && continue
  OUT="exports/$(echo "${NAME}_${TITLE}" | tr ' /' '__' | sed 's/_$//').3mf"
  echo "-> $OUT"
  eval "\"$OPENSCAD\" -o \"$OUT\" -D 'name=\"${NAME//\"/}\"' -D 'title=\"${TITLE//\"/}\"' $LOGO_ARGS $EXTRA tag.scad" 2>/dev/null
done < "$CSV"
echo "done. files are in exports/"
