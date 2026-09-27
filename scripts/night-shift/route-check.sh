#!/usr/bin/env bash
# Find every place the gateway still points at the Mac's LAN address, and optionally repoint it to Tailscale.
# Usage (via ns-route): route-check.sh [fix]
# Why: in models "merge" mode, a non-empty baseUrl in an agent's generated models.json
# wins over models.providers.*.baseUrl in openclaw.json, so a config-only change is not enough.
set -u
OLD="10.10.1.201"; NEW="100.87.4.93"; MODE="${1:-check}"
cd "$HOME/.openclaw" || exit 1
echo "== 1. Files under ~/.openclaw still naming the LAN address ($OLD)"
hits=$(grep -rIl --exclude='*.bak*' --exclude-dir=sessions --exclude-dir=transcripts "$OLD" . 2>/dev/null)
[ -n "$hits" ] && echo "$hits" | sed 's/^/  /' || echo "  none"
echo "== 2. Files naming the Tailscale address ($NEW)"
grep -rIl --exclude='*.bak*' --exclude-dir=sessions --exclude-dir=transcripts "$NEW" . 2>/dev/null | sed 's/^/  /'
echo "== 3. Model catalog mode and lmstudio baseUrl per agent models.json"
openclaw config get models.mode < /dev/null 2>/dev/null || echo "  models.mode unset (default merge)"
for f in agents/*/agent/models.json; do [ -f "$f" ] || continue
  python3 - "$f" <<'P'
import json,sys
f=sys.argv[1]; d=json.load(open(f)); p=d.get("providers",d)
for k,v in (p.items() if isinstance(p,dict) else []):
    if isinstance(v,dict) and "baseUrl" in v: print(f"  {f}: {k} -> {v['baseUrl']}")
P
done
if [ "$MODE" = "fix" ] && [ -n "$hits" ]; then
  echo "== 4. Repointing $OLD -> $NEW (backup beside each file)"
  ts=$(date +%Y%m%d-%H%M%S)
  for f in $hits; do case "$f" in *.json|*.json5|*.md) cp "$f" "$f.bak-$ts"; sed -i "s/$OLD/$NEW/g" "$f"; echo "  fixed $f";; *) echo "  skipped $f (not json/md; review by hand)";; esac; done
  echo "== 5. Restart gateway so agents reload their model catalog"
  openclaw gateway restart < /dev/null 2>&1 | tail -3
  sleep 8
  left=$(grep -rIl --exclude='*.bak*' --exclude-dir=sessions --exclude-dir=transcripts "$OLD" . 2>/dev/null)
  [ -z "$left" ] && echo "  CLEAN: no live file names $OLD" || { echo "  still naming $OLD:"; echo "$left" | sed 's/^/    /'; }
fi
