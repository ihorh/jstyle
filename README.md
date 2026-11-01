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

The skill suits everyday writing: manuals and documentation with a human touch,
code comments and docstrings, friendly and professional conversations, many
kinds of blog posts, and perhaps marketing copy.

It isn't meant for text that follows its own rules, such as legal documents,
government papers, or machinery specifications. It's also unlikely to suit
creative writing.

## Before and After

Coming soon: passages from the benchmark, written by the same model without
the skill and with it.

## Install

Install it once in any of these, and it works in the other two on the same
computer: the terminal, the VS Code extension, and the desktop app's local
sessions. Cloud sessions, such as claude.ai/code, don't load it.

- **In a terminal session** (Claude Code 2.1.275 or later), run this, then
  choose a scope:

  ```
  /plugin install jstyle --marketplace ihorh/jstyle
  ```

- **From your shell** (Claude Code 2.1.292 or later), run this. The plugin
  loads in your next session, or after `/reload-plugins` in an open one:

  ```
  claude plugin install jstyle --marketplace ihorh/jstyle
  ```

- **In VS Code,** type `/plugins` in the Claude Code panel, add `ihorh/jstyle`
  on the **Marketplaces** tab, then install `jstyle` from the **Plugins** tab.
- **In the desktop app,** open the **Code** tab, click **+** next to the
  prompt box, choose **Add plugins**, and select `jstyle`. If it isn't listed,
  add the marketplace from your shell first:
  `claude plugin marketplace add ihorh/jstyle`.

Adding the marketplace clones the whole repository, benchmark included. Only
the plugin folder is copied into a session. For a smaller clone, add it this
way before you install:

```
claude plugin marketplace add ihorh/jstyle --sparse .claude-plugin plugins
```

## Turn It Off or Remove It

To compare writing with and without the skill, turn it off and on again
without uninstalling. In a session, run `/plugin`, and on the **Installed**
tab press **Space** on `jstyle`. From your shell:

```
claude plugin disable jstyle@jstyle
claude plugin enable jstyle@jstyle
```

To remove it, run `/plugin uninstall jstyle@jstyle` in a session, or this from
your shell. The second line also drops the marketplace:

```
claude plugin uninstall jstyle@jstyle
claude plugin marketplace remove jstyle
```

[Install and manage plugins](https://code.claude.com/docs/en/discover-plugins)
in the Claude Code docs covers scopes, updates, and the rest.

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

## Disclaimer

jstyle shapes how an agent writes. It doesn't check facts, and it doesn't make
text fit for legal, regulatory, medical, or safety-critical use. Review what an
agent writes before you send or publish it. The software comes with no
warranty, as the [MIT License](LICENSE) states.

## Credits

Written by Ihor H., with Claude (Anthropic) as co-author of the skill, the
benchmark, and this README.

## License

Copyright © 2026 Ihor H. Released under the [MIT License](LICENSE).
