#!/usr/bin/env bash
# Write a run's manifest.json: what ran, on which model, against which inputs.
#
# Usage: lib/manifest.sh OUT
# Reads MODEL, EFFORT, CONDS, SAMPLES, TASKS, DIRTY, and PLUGIN from the
# environment.
set -euo pipefail

out=$1
bench="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
commit() { git -C "$bench" log -1 --format=%H -- "$@" 2>/dev/null || true; }

skill_commit=""
if [[ " $CONDS " == *" skill "* ]]; then
  [[ -d "$PLUGIN" ]] || { echo "no plugin at $PLUGIN" >&2; exit 1; }
  skill_commit="$(commit ../plugins/jstyle)"
fi

mkdir -p "$(dirname "$out")"
cat > "$out" <<JSON
{
  "date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "model": "$MODEL",
  "effort": "${EFFORT:-default}",
  "claude_code": "$(claude --version | head -1)",
  "conditions": "$CONDS",
  "samples": $SAMPLES,
  "tasks": "$TASKS",
  "inputs_commit": "$(commit world tasks)",
  "skill_commit": "$skill_commit",
  "dirty": $DIRTY
}
JSON
