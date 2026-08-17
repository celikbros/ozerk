#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
#
# TR: Depo içi göreli Markdown bağlantılarının hedeflerini denetler.
#     Dış bağlantılar (http/https/mailto) ve saf çapalar (#bolum) atlanır.
# EN: Checks that in-repo relative Markdown link targets exist.
#     External links (http/https/mailto) and pure anchors (#section) are skipped.

set -uo pipefail

status=0

while IFS= read -r file; do
  dir=$(dirname "$file")
  while IFS= read -r link; do
    case "$link" in
      http://* | https://* | mailto:*) continue ;;
      \#*) continue ;;
    esac
    target="${link%%#*}"
    [ -z "$target" ] && continue
    if [ ! -e "$dir/$target" ]; then
      echo "KIRIK / BROKEN: $file -> $link"
      status=1
    fi
  done < <(grep -oE '\]\([^)]+\)' "$file" | sed -E 's/^\]\(//; s/\)$//')
done < <(find . -name '*.md' -not -path './.git/*' -not -path '*/target/*')

if [ "$status" -eq 0 ]; then
  echo "Tüm depo içi bağlantılar geçerli. / All in-repo links are valid."
fi

exit "$status"
