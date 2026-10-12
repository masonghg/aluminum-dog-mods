#!/usr/bin/env bash
# Publish a mod zip into this repo (website pulls automatically).
# Usage: ./scripts/publish-mod.sh <mod-id> <path-to-zip> [version] [changelog]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MOD_ID="${1:-}"
ZIP_PATH="${2:-}"
VERSION="${3:-}"
CHANGELOG="${4:-Published via scripts/publish-mod.sh}"

if [[ -z "$MOD_ID" || -z "$ZIP_PATH" ]]; then
  echo "Usage: $0 <mod-id> <path-to-zip> [version] [changelog]" >&2
  exit 1
fi
if [[ ! -f "$ZIP_PATH" ]]; then
  echo "Zip not found: $ZIP_PATH" >&2
  exit 1
fi

DEST="$ROOT/${MOD_ID}.zip"
MANIFEST="$ROOT/manifest.json"

python3 - "$MANIFEST" "$MOD_ID" "$VERSION" "$CHANGELOG" <<'PY'
import json, sys, datetime
from pathlib import Path
manifest_path, mod_id, version, changelog = sys.argv[1:5]
data = json.loads(Path(manifest_path).read_text())
mods = data.get("mods", [])
match = next((m for m in mods if m.get("id") == mod_id), None)
if match is None:
    known = ", ".join(m.get("id", "?") for m in mods) or "(none)"
    raise SystemExit(f"Unknown mod id '{mod_id}'. Known: {known}")
now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
if version:
    match["version"] = version
elif str(match.get("version", "")).endswith("placeholder"):
    match["version"] = "0.1.0"
match["status"] = "available"
match["updatedAt"] = now
match["changelog"] = changelog
match["file"] = f"{mod_id}.zip"
data["updatedAt"] = now
Path(manifest_path).write_text(json.dumps(data, indent=2) + "\n")
print(f"Updated manifest entry for {mod_id} -> v{match['version']}")
PY

if [[ "$(realpath "$ZIP_PATH")" != "$(realpath -m "$DEST")" ]]; then
  cp "$ZIP_PATH" "$DEST"
fi
echo "Wrote $DEST ($(wc -c < "$DEST") bytes)"
echo "Next: git add -A && git commit -m \"Publish ${MOD_ID} ${VERSION:-update}\" && git push"
