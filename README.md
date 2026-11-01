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

In a Claude Code terminal session, version 2.1.275 or later, run this and
choose a scope:

```
/plugin install jstyle --marketplace ihorh/jstyle
```

`/plugins` opens the same plugin manager in the VS Code extension, and the
desktop app has an **Add plugins** button under **+** next to the prompt box.
A plugin you install in one of the three is available in the others on the
same computer. [Install and manage
plugins](https://code.claude.com/docs/en/discover-plugins) in the Claude Code
docs covers the other ways to install, scopes, and uninstalling.

Adding the marketplace clones the whole repository, benchmark included, though
only the plugin folder is copied into a session. For a smaller clone, add the
marketplace from your shell first, then install `jstyle@jstyle`:

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

## Turn It Off and On

To compare writing with and without the skill, turn it off and on again
without uninstalling:

- **In a terminal session,** run `/plugin`, and on the **Installed** tab press
  **Space** on `jstyle`.
- **In VS Code,** type `/plugins` and use the toggle next to `jstyle`.
- **In the desktop app,** click **+**, then **Plugins**, then **Manage
  plugins**.

In the terminal and in VS Code, a change applies to the open session without
a restart. In a terminal session,
when reloading the plugins would invalidate the prompt cache, Claude Code
warns you and leaves the change pending. Run `/reload-plugins --force` to apply
it anyway. A skill that already loaded stays in the conversation, so start a
new session for a clean comparison. The docs page above lists the other ways
to do this, including from your shell.

## Other Languages and Models

We have tested the skill only in English, and only with Claude models in
Claude Code. Its principles and its handling of facts don't depend on English,
so it is likely to help in other languages too. The sentence traps are written
for English, and the skill lets each language's own grammar decide their
details. If you use it in another language, or with another model or agent,
we'd like to hear how it changed the prose: [open an
issue](https://github.com/ihorh/jstyle/issues).

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

## Punctuation and Case

[rules/punctuation-and-case.md](rules/punctuation-and-case.md) is a separate
file, not part of the plugin. It asks for the Oxford comma, Chicago title case
in headings, and punctuation that takes the style of the text it belongs to.
It gives way to any style the document or the project already uses. If you
like these conventions, put the file in your rules folder, such as
`~/.claude/rules/`, or paste it into a system prompt.

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

## Background

The skill grew out of personal writing rules that Ihor H. has used in his
Claude Code sessions for over three months. In October 2026, Claude measured
its own output under those rules: 784 chat replies and 63 documents from 50
sessions. The habits Ihor suspected, such as dropping the word *that*,
explained little. Two habits he hadn't suspected cost more: phrases with no
verb, often after a colon, in 3 to 4 of every 100 replies, and clauses nested
three deep, in about 2 of every 100 sentences. That finding is why the skill
targets compression.

The skill also draws on writing and reading research:

- **Garden-path sentences** (Bever, 1970). Readers slow down on a sentence
  such as *I'll confirm your files match*, where a missing *that* invites the
  wrong first reading (Ferreira and Henderson, 1990; Trueswell, Tanenhaus, and
  Kello, 1993).
- **The curse of knowledge** (Pinker, *The Sense of Style*, 2014). A writer's
  own context fills the gaps in their text, which is why the skill asks for a
  cold read.
- **Revision as reordering** (Sommers, 1980). Experienced writers treat each
  addition as a change to the whole, which is why the skill rereads one level
  up after an edit.

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
