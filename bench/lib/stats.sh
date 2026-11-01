#!/usr/bin/env bash
# Summarize a run's sessions: mean tokens, time, and turns per task and condition.
#
# Usage: lib/stats.sh RUN_DIR
# Reads every outputs/<task>/<condition>-<n>.json in RUN_DIR. "input" counts all
# input tokens, cached or not. "thinking" is part of "output".
set -euo pipefail

run=$1
shopt -s nullglob
files=("$run"/outputs/*/*.json)
[[ ${#files[@]} -gt 0 ]] || { echo "no session JSON in $run/outputs" >&2; exit 1; }

jq -rn '
  def avg(f): (map(f) | add / length | floor);
  [inputs | {
     task: (input_filename | split("/")[-2]),
     cond: (input_filename | split("/")[-1] | split("-")[0]),
     model: (.modelUsage | keys | join(",")),
     input: (.usage.input_tokens + .usage.cache_creation_input_tokens
             + .usage.cache_read_input_tokens),
     output: .usage.output_tokens,
     thinking: (.usage.output_tokens_details.thinking_tokens // 0),
     turns: .num_turns,
     secs: (.duration_ms / 1000)
   }]
  | group_by([.task, .cond])
  | (["task", "cond", "n", "model", "input", "output", "thinking", "turns", "secs"]),
    (.[] | [.[0].task, .[0].cond, length, .[0].model,
            avg(.input), avg(.output), avg(.thinking), avg(.turns), avg(.secs)])
  | @tsv' "${files[@]}" | column -t
