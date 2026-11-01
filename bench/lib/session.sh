#!/usr/bin/env bash
# Run one task in a fresh `claude -p` session and write its output.
#
# Usage: lib/session.sh TASK CONDITION OUT
# Reads MODEL, EFFORT, and PLUGIN from the environment.
#
# The session starts in a temporary copy of world/, with read-only tools and no
# user or project settings, so no personal rules, memory, plugins, or MCP
# servers reach it. The `skill` condition adds the plugin with --plugin-dir.
#
# OUT gets the text, and OUT with .json in place of .md gets the session's raw
# JSON: usage, timing, turns, and the resolved model. Both appear only when the
# session succeeds, so make retries a failed one.
set -uo pipefail

task=$1 cond=$2 out=$3
bench="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"

args=(-p --model "$MODEL" --setting-sources local --strict-mcp-config
      --tools "Read,Glob,Grep" --no-session-persistence --output-format json)
[[ -n "${EFFORT:-}" ]] && args+=(--effort "$EFFORT")
[[ "$cond" == skill ]] && args+=(--plugin-dir "$PLUGIN")

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
cp -R "$bench/world/." "$work/"

json="${out%.md}.json"
mkdir -p "$(dirname "$out")"
if (cd "$work" && claude "${args[@]}" < "$bench/tasks/$task/prompt.md") \
     > "$json.tmp" 2> "$out.err" \
   && jq -e '.is_error == false' "$json.tmp" > /dev/null \
   && jq -r '.result' "$json.tmp" > "$out.tmp"; then
  mv "$json.tmp" "$json"
  mv "$out.tmp" "$out"
  [[ -s "$out.err" ]] || rm -f "$out.err"
  echo "done   $task $cond"
else
  rm -f "$out.tmp"
  [[ -f "$json.tmp" ]] && mv "$json.tmp" "$out.err.json"
  echo "FAILED $task $cond (see $out.err)"
  exit 1
fi
