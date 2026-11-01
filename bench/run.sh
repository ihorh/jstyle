#!/usr/bin/env bash
# Run the benchmark with `claude plugin eval` and copy the results for analysis.
#
# Usage: bench/run.sh MODEL [eval options]
#
#   bench/run.sh claude-opus-5-5                                  full run
#   bench/run.sh claude-opus-5-5 --case 03-email --runs 1         one task, cheap
#   bench/run.sh claude-opus-5-5 --case 03-email --runs 1 --ablation none
#                                                     skill arm only, cheaper
#
# Every task runs 3 times with the skill and 3 times without it, unless the
# options say otherwise. Each session starts in a copy of world/ (see
# scaffold.sh) with the tools in its task's case.yaml, and nothing personal
# reaches it. Set ALLOW_DIRTY=1 to run with uncommitted world/ or tasks/.
#
# The run goes to runs/<date>-<model>/:
#   manifest.json                     what ran, on which model and inputs
#   eval/                             the eval tool's own result and report
#   outputs/<task>/<cond>-<n>.md      the reply, cond being base or skill
#   outputs/<task>/<cond>-<n>.json    the session's result: usage, cost, turns
#   outputs/<task>/<cond>-<n>.jsonl   the full trace, subagents included
#
# In the .json, `usage` counts the main session only, and `modelUsage` and
# `total_cost_usd` include subagents. lib/stats.sh summarizes a run.
set -euo pipefail

model=${1:?usage: bench/run.sh MODEL [eval options]}
shift
# A full model ID, never an alias: an alias like `opus` moves when a model ships.
[[ $model == claude-* ]] || { echo "MODEL must be a full model ID, such as claude-opus-5-5" >&2; exit 1; }

bench="$(CDPATH='' cd -- "$(dirname "$0")" && pwd)"
root="$(dirname "$bench")"
commit() { git -C "$bench" log -1 --format=%H -- "$@"; }

# The manifest names the commit of world/ and tasks/, so they must be committed.
dirty=false
[[ -z "$(git -C "$bench" status --porcelain -- world tasks)" ]] || dirty=true
if [[ $dirty == true && -z "${ALLOW_DIRTY:-}" ]]; then
  echo "world/ or tasks/ has uncommitted changes. Commit them, or set ALLOW_DIRTY=1" >&2
  exit 1
fi

run="$bench/runs/$(date +%F)-$model"
n=2
while [[ -e $run ]]; do run="$bench/runs/$(date +%F)-$model-$n"; n=$((n + 1)); done
mkdir -p "$run/eval"

cat > "$run/manifest.json" <<JSON
{
  "date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "model": "$model",
  "claude_code": "$(claude --version | head -1)",
  "eval_options": "$*",
  "inputs_commit": "$(commit world tasks)",
  "skill_commit": "$(commit ../plugins/jstyle)",
  "dirty": $dirty
}
JSON

# Later options override the defaults before them.
status=0
(cd "$root" && claude plugin eval . --eval-dir bench/tasks --scaffold \
   --trust-plugin --no-publish --keep-temp --model "$model" --runs 3 -j 4 \
   --output-dir "$run/eval" "$@") || status=$?

# Copy each session's trace out of the eval tool's temporary directory, then
# delete that directory, which the tool leaves read-only.
jq -r '.cases[] | .name as $task | .arms | to_entries[]
       | (if .key == "with" then "skill" else "base" end) as $cond
       | .value | to_entries[]
       | [$task, $cond, (.key + 1), (.value.tracePath // "")] | @tsv' \
   "$run/eval/aggregate-result.json" |
while IFS=$'\t' read -r task cond i trace; do
  out="$run/outputs/$task/$cond-$i"
  mkdir -p "$(dirname "$out")"
  if [[ -f $trace ]]; then
    cp "$trace" "$out.jsonl"
    jq -s 'map(select(.type == "result")) | last' "$trace" > "$out.json"
    jq -r '.result // empty' "$out.json" > "$out.md"
    tmp="$(dirname "$(dirname "$trace")")"
    chmod -R u+rwx "$tmp" && rm -rf "$tmp"
  else
    echo "no trace for $task $cond-$i" >&2
  fi
done

echo "results: $run"
exit $status
