# Usage on One Working Day

*2 November 2026. A note for the maintainers.*

What one ordinary working day with jstyle installed cost, and where the cost
went. The day ran a little heavier on prose than usual: most of it went into
writing and revising markdown documents in this repository.

## How It Was Measured

- **Source.** The Claude Code session logs on one machine, covering the 24
  hours up to the evening of 2 November. Each assistant request was counted
  once, by its message ID.
- **Prices.** List price for Claude Opus 5.5 ($4 input, $20 output per million
  tokens) and Claude Sonnet 5.5 ($2 and $10), with cache reads at $0.20. Every
  cache write is priced at the 1-hour rate, twice the input price. Writes at
  the 5-minute rate would lower the total by about $4.
- **What it isn't.** It isn't what a subscription bills, and it covers one
  day on one machine.

## Numbers

| Where | Requests | List price | Share |
|---|---|---|---|
| Main sessions in this repository (Opus) | 607 | $35.82 | 81% |
| A main session in another project (Opus) | 119 | $5.07 | 11% |
| Cold reads run as separate `claude -p` sessions (Opus and Sonnet) | 18 | $1.51 | 3% |
| Subagents, mostly cold reads (Opus and Sonnet) | 12 | $1.96 | 4% |
| **Total** | | **about $44** | |

In this repository's main sessions, cache reads cost $20.73, cache writes
$8.53, and output $6.56. Requests there averaged about 170,000 tokens of
context.

The skill file is 10 KB, about 2,500 tokens, or roughly 1.5% of an average
request's context. Carried through every request that day, it cost about
$0.30 in cache reads.

Claude Code's own usage panel showed, for the same 24 hours, the jstyle plugin
at 4% and general-purpose subagents at 2%. How the panel attributes usage
isn't documented, so its figures and these may not count the same things.

## Provisional Conclusions

- **The skill text is not the cost.** At about 1.5% of each request's context,
  it costs less than one extra turn would.
- **Cold reads cost a few percent of a day.** Together they came to about
  $3.50, or about 8% of the day. A pair of readers, Opus and Sonnet, on a
  page of about 2,500 words cost about $0.30.
- **Long sessions are the main cost.** Most of the spend was cache reads from
  resending a long conversation on every turn. One session ran from one task
  into several unrelated ones. The panel's top suggestion, to start fresh when
  switching tasks, points at the same thing.
- **The benchmark ratio doesn't carry over.** The benchmark's cold sessions
  cost about 1.8 times as much with the skill. On a working day, the skill's
  direct share looks far smaller, but one day doesn't show how much extra
  drafting and rereading it caused.

To firm these up, repeat the count on a few more days, including a day with
little prose.
