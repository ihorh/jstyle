# jstyle

An opinionated writing style for agents that write for people. Work in
progress: the benchmark comes first, and the skill follows it.

Most writing advice fights wordiness. This skill fights compression instead:
the dropped words, verbless fragments, and packed clauses that save the writer
a token and cost the reader a second pass.

## Which Models It Assumes

The skill was written for Claude and other recent models. It states intent
more than procedure, and it relies on the model's judgment to apply it.

Some of its entries may be unnecessary for the models we test on, and they stay
for models we haven't tested. Cold readers on Claude Opus and Sonnet 5.5 judged
these redundant, because those models rarely make the mistake:

- the center embedding trap
- the noun stack trap
- the overloaded sentence trap

## Benchmark Reports

The latest report for each standing comparison. The recipe behind them is in
[bench/reports/README.md](bench/reports/README.md).

The reports show excerpts and one reader's scores. Every output behind them is
in the repository, under `bench/runs/`, together with the task prompts and the
project files the models worked from. Clone it and make your own review or 
ask your own agent to compare the runs and draw its own conclusions (TODO: need to soften this sentence or whole paragraph).

| Comparison | Latest report |
|---|---|
| Sonnet 5.5 vs Opus 5.5, both without the skill | [2026-11-01](bench/reports/2026-11-01-sonnet-vs-opus-baseline.md) |
| Opus 5.5 without the skill vs with it | not yet: the skill doesn't exist |
| Opus 5.5 without the skill vs Sonnet 5.5 with it | not yet: the skill doesn't exist |


