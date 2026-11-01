# jstyle

An opinionated writing style for agents that write for people: full sentences,
sourced facts, and nothing the reader has to unpack.

It ships as a Claude Code plugin with one skill, `/jstyle:write`, and a
benchmark that compares writing with and without it. Work in progress.

Most writing advice fights wordiness. This skill fights compression instead:
the dropped words, verbless fragments, and packed clauses that save the writer
a token and cost the reader a second pass.

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
the plugin folder is copied into a session. For a smaller clone, run
`claude plugin marketplace add ihorh/jstyle --sparse .claude-plugin plugins`.

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
