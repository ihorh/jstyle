# jstyle

> [!WARNING]
> Work in progress. The skill is drafted, and the benchmark hasn't measured it
> yet.

An opinionated prose style for AI agents that write for people.

It ships as a Claude Code plugin with one skill, `/jstyle:write`, and a
benchmark that compares writing with and without it.

Writing advice is often about cutting words. This skill works against compression
instead: the dropped words, verbless fragments, and packed clauses that save
the writer a token and cost the reader a second pass. It works for clear
ideas that keep the details a reader needs, in text that sticks to the facts
and reads in one pass.

## Before and After

Coming soon: passages from the benchmark, written by the same model without
the skill and with it.

## Install

In Claude Code 2.1.275 or later:

```
/plugin install jstyle --marketplace ihorh/jstyle
```

Or add the marketplace first, then install:

```
/plugin marketplace add ihorh/jstyle
/plugin install jstyle@jstyle
```

Adding the marketplace clones the whole repository, benchmark included. Only
the plugin folder is copied into a session. For a smaller clone, run:

```
claude plugin marketplace add ihorh/jstyle --sparse .claude-plugin plugins
```

## Using It

Call it before you ask for a draft:

```
/jstyle:write
```

You can also just ask. In Claude Code the agent loads the skill on its own
when it drafts text for someone outside the conversation, such as an email or
a README, and leaves it off for ordinary chat replies. Other harnesses that
support skills will likely route it the same way, but we haven't tested them.
[docs/trigger-test.md](docs/trigger-test.md) has the test behind this.

Where skills aren't supported, such as a chat app, you can:

- paste [SKILL.md](plugins/jstyle/skills/write/SKILL.md) into the context
  before asking for a draft, or
- add a line to your instructions file that points at it, such as: "Before
  drafting text for a reader outside this conversation, read
  `<path>/SKILL.md` and follow it."

The skill was written for Claude and other recent models.
[docs/models.md](docs/models.md) says what that means for its contents.

## What It Asks For

The skill puts correct facts and a clear idea ahead of brevity. It works on
four levels:

- **Facts.** The agent lists its facts with their sources before writing any
  prose, and marks the conclusions it drew itself as its own.
- **The idea.** When a sentence stays unclear after rewording, the agent works
  out the idea, or the context the reader is missing, before writing it again.
- **Concise, never compressed.** It cuts sentences that carry nothing, and
  keeps the small words that let the rest read in one pass.
- **Sentence traps.** It watches for patterns known to make a reader stop and
  reparse, such as garden-path sentences, stacked negations, and hidden actors.

## Benchmark Reports

The latest report for each standing comparison. The recipe behind them is in
[bench/reports/README.md](bench/reports/README.md).

Each report shows excerpts and one reader's scores, so it reflects one
person's taste. The full outputs are in the repository under `bench/runs/`,
with the task prompts and the project files the models worked from. If you
want a second opinion, compare the runs yourself, or ask your own agent to.

| Comparison | Latest report |
|---|---|
| Sonnet 5.5 vs Opus 5.5, both without the skill | [2026-11-01](bench/reports/2026-11-01-sonnet-vs-opus-baseline.md) |
| Opus 5.5 without the skill vs with it | not yet run |
| Opus 5.5 without the skill vs Sonnet 5.5 with it | not yet run |

## Credits

Written by Ihor H., with Claude (Anthropic) as co-author of the skill, the
benchmark, and this README.

## License

Copyright © 2026 Ihor H. Released under the [MIT License](LICENSE).
