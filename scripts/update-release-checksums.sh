#!/usr/bin/env bash
# After attaching the privately built disk image, checksum every draft asset.
# Usage: scripts/update-release-checksums.sh v1.2.0
set -euo pipefail
ref="${1:?Usage: scripts/update-release-checksums.sh TAG}"
repo="laurielaptop/phantasm-os"
[ "$(gh release view "$ref" --repo "$repo" --json isDraft --jq .isDraft)" = true ] || {
  echo 'Refusing to change checksums on a published release.' >&2; exit 1;
}
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
gh release download "$ref" --repo "$repo" --dir "$stage"
python3 - "$stage" <<'PYCODE'
import hashlib
from pathlib import Path
import sys
stage = Path(sys.argv[1])
assets = sorted(p for p in stage.iterdir() if p.is_file() and p.name != 'SHA256SUMS')
if not any(p.suffix.lower() == '.hfe' for p in assets):
    raise SystemExit('Attach the .hfe disk image before finalizing checksums.')
with (stage / 'SHA256SUMS').open('w') as output:
    for asset in assets:
        if any(c in asset.name for c in '\r\n\\'):
            raise SystemExit('Unsupported asset filename: ' + repr(asset.name))
        output.write(hashlib.sha256(asset.read_bytes()).hexdigest() + '  ' + asset.name + '\n')
PYCODE
gh release upload "$ref" "$stage/SHA256SUMS" --repo "$repo" --clobber
echo "Updated SHA256SUMS for all draft assets on $ref."
