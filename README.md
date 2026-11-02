<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset=".github/readme/icon-a-dark.svg">
    <img src=".github/readme/icon-a-light.svg" width="128" height="128" alt="jstyle logo: an ensō, a circle drawn in one brush stroke">
  </picture>
</p>

<h1 align="center">jstyle</h1>

<p align="center"><i>An opinionated prose style for your AI agent,<br>so more of what you write gets read.</i></p>

<p align="center">
  <a href="#install">Install</a> ·
  <a href="#an-example">An Example</a> ·
  <a href="#how-it-writes">How It Writes</a>
</p>

<br>

**[Readers stay with your text.](#how-it-writes)** The skill makes the first
lines count, and keeps each sentence readable in one pass.

**[Cold reads find the gaps.](#cold-reads)** A fresh reader, with none
of the agent's context, points out what the agent can't see in its own text.

Agents write well now, so what goes wrong is small. A text opens with
background instead of what the reader came for. A sentence has to be read
twice. A paragraph's point arrives late. Each slip is minor, but together
they make prose that is good enough and slightly off. You feel it before you
can say why.

So do your readers. They take in text a few words at a time, and the first
few decide whether they stay. The skill aims to make those words count.
Your reader stays with you instead of asking their agent for a summary, and
more of what you write gets read.

The skill is for text a **person** will read: documentation and manuals, code
comments and docstrings, emails and conversations, many kinds of blog
posts, and perhaps marketing copy.

It isn't for text that answers to a rulebook before a reader, such as legal
documents, government papers, or machinery specifications. It's also
unlikely to suit creative writing.

jstyle is a Claude Code plugin with one skill, `/jstyle:write`, which your
agent loads automatically when it writes for someone else. The repository also
holds a benchmark and other supporting material.

## An Example

One task from the first **blind benchmark**: Opus 5.5 updates a CSV tool's
README, so users learn how it handles very long rows before they run into
them.

Without the skill:

> A quoted field can contain newlines, as RFC 4180 allows. The field stays in
> one row. Each row is limited to `--max-row-bytes`, measured in UTF-8 bytes
> and not counting the newline at the end. The limit stops one stray `"` from
> turning the rest of the file into a single field.
>
> When a row goes over the limit, splitlane:
>
> 1. Keeps the first `--max-row-bytes` bytes of the row and writes them to the
>    chunk as a normal row. The rest of the row is dropped, so the written row
>    can have missing columns or an unclosed quote.

With the skill:

> splitlane cuts a row that is longer than `--max-row-bytes` and still writes it.
> It does not skip the row. The chunk gets the first `--max-row-bytes` bytes of
> the row, and splitlane drops the rest of the row up to the next line break. The
> cut usually falls in the middle of a field. The row that gets written can then
> have too few columns or an unclosed quote. An importer may reject it, or accept
> the shortened row without noticing.

The maintainer picked the version with the skill without knowing which was
which, because the other "lost my attention after mentioning RFC 4180." The
version without the skill is the best of its three tries, and the one with
the skill is its first. The
[report](bench/reports/2026-11-01-opus-without-vs-with-skill.md) has the rest
of the story: nine more tasks, and the reason behind every pick.

## Install

In a Claude Code terminal session, version 2.1.275 or later, run this,
confirm adding the marketplace, and choose a scope:

```
/plugin install jstyle --marketplace ihorh/jstyle
```

The VS Code extension and the desktop app have plugin menus too. Add the
`ihorh/jstyle` marketplace there first, then install `jstyle`. A plugin you
install in one is available in the others on the same computer. [Install
and manage plugins](https://code.claude.com/docs/en/discover-plugins) in the
Claude Code docs covers the other ways to install, scopes, and uninstalling.

Updates don't arrive on their own. Claude Code turns auto-update off by
default for marketplaces outside Anthropic's own, and this one is outside. To
turn it on, run `/plugin`, select `jstyle` on the **Marketplaces** tab, and
choose **Enable auto-update**. To update once instead, run
`claude plugin update jstyle@jstyle` from your shell.

Adding the marketplace clones the whole repository, benchmark included, though
only the plugin folder is copied into a session. For a smaller clone, add the
marketplace from your shell first, then install the plugin from it:

```
claude plugin marketplace add ihorh/jstyle --sparse .claude-plugin plugins
claude plugin install jstyle@jstyle
```

## Using It

Ask for the text as usual. The agent loads the skill when it writes for
someone outside the conversation, such as an email or a README, and leaves it
off for chat replies.

To load it yourself, start your request with the command:

```
/jstyle:write [your writing prompt]
```

Some agents and tools see the skill only after it has run once. If yours
doesn't pick it up, run the command on its own first. The skill then stays in
the conversation:

```
/jstyle:write
```

Where skills aren't supported, such as a chat app, you can:

- paste [SKILL.md](plugins/jstyle/skills/write/SKILL.md) into the context
  before asking for a draft, or
- add a line to your instructions file that points at it, such as: "Before
  drafting text for a reader outside this conversation, read
  `<path>/SKILL.md` and follow it."

The skill was written for Claude and other recent models.
[docs/models.md](docs/models.md) says what that means for its contents.

### Cold Reads

Some text gets one chance with a reader who doesn't share the writer's
context, such as an email, a README, or release notes. For that text, the
skill asks the agent for a cold read before it hands the text over. A subagent
or a new session on the same model gets only the text and one line on who it's
for, and lists what it had to reread or couldn't follow. A writer can't find
these gaps alone, because their own context fills them in. Chat replies and
small edits skip this step.

A cold read costs extra tokens and time. Where the agent can start a subagent,
the skill tells it to run one without asking, unless your instructions limit
background work. If that's a concern, add a line to your instructions file,
such as "Ask before starting a subagent."

> [!TIP]
> Agents are careful with tokens, so they may skip the cold read, or check
> only the sentence they changed. When a text matters, ask in the chat: "Run
> a cold read on this," or "Reread the whole section after that change."

## Turn It Off and On

To compare writing with and without the skill, turn it off and on again
without uninstalling:

- **In a terminal session,** run `/plugin`, and on the **Installed** tab press
  **Space** on `jstyle`.
- **In VS Code,** type `/plugins` and use the toggle next to `jstyle`.
- **In the desktop app,** use its plugin menu.

> [!IMPORTANT]
> Start a new session after each change. A skill that already loaded stays in
> the conversation, so an open session can't show writing without it.

[Install and manage plugins](https://code.claude.com/docs/en/discover-plugins)
lists the other ways to turn a plugin off and on, including from your shell.

## Other Languages and Models

We have tested the skill only in English, and only with Claude models in
Claude Code. Its principles and its handling of facts don't depend on English,
so it is likely to help in other languages too. The sentence traps are written
for English, and the skill lets each language's own grammar decide their
details.

If you use it in another language, or with another model or agent,
we'd like to hear how it changed the prose. The [feedback
form](https://github.com/ihorh/jstyle/issues/new?template=feedback.yml) opens
a new issue with one required box, and a few lines in it are enough. Issues
are public.

## How It Writes

The skill puts sourced facts and a clear idea ahead of brevity. It starts
from the facts, then works from the idea down to the words.

- **Facts.** The agent lists its facts with their sources before writing any
  prose, and marks the conclusions it drew itself as its own. The list stays
  in its working notes, and the finished text cites a source only where the
  reader needs one.
- **The idea.** When a sentence stays unclear after rewording, the agent works
  out what it means to say, or what context the reader is missing, before
  writing it again.
- **Paragraphs.** After an edit, the agent rereads the paragraph around it, and
  the section too when the paragraph's point has shifted. A [cold
  read](#cold-reads) finds what the agent's own reread passes over.
- **Sentences.** It watches for patterns known to make a reader stop and
  reparse, such as garden-path sentences, stacked negations, and hidden actors.
- **Words.** It is concise, never compressed: it cuts sentences that carry
  nothing, and keeps the small words that let the rest read in one pass.

Looking back at the blind picks, the maintainer finds that most of the
difference came at the paragraph level.

## Punctuation and Case

[rules/punctuation-and-case.md](rules/punctuation-and-case.md) is a separate
file, not part of the plugin. It asks for the Oxford comma, Chicago title case
in headings, and punctuation that takes the style of the text it belongs to.
It gives way to any style the document or the project already uses. If you
like these conventions, put the file in your rules folder, such as
`~/.claude/rules/`, or paste it into a system prompt.

## Benchmark Reports

The table links the latest report for each standing comparison, one we rerun
whenever a run it depends on changes.

- [bench/reports/LOG.md](bench/reports/LOG.md) sums up every report, newest
  first.
- [bench/reports/README.md](bench/reports/README.md) is the recipe behind the
  reports.

Each report shows excerpts and the picks of at most two readers: the
maintainer's, made blind, and the report writer's. So it reflects a narrow
taste. The full outputs are in the repository under `bench/runs/`,
with the task prompts and the project files the models worked from. If you
want a second opinion, compare the runs yourself, or ask your own agent to.

| Comparison | Latest report |
|---|---|
| Sonnet 5.5 vs Opus 5.5, both without the skill | [2026-11-01](bench/reports/2026-11-01-sonnet-vs-opus-baseline.md) |
| Opus 5.5 without the skill vs with it | [2026-11-01](bench/reports/2026-11-01-opus-without-vs-with-skill.md) |
| Sonnet 5.5 without the skill vs with it | [2026-11-01](bench/reports/2026-11-01-sonnet-without-vs-with-skill.md) |

The benchmark's sessions are cold: each one started fresh and wrote a
single text. There, at API list price, a session with the skill cost about
1.8 times as much as one without it. In a normal working session we expect
the difference to be much smaller. The skill's own text loads once, and in a
long session it soon becomes a small share. The rest goes to the drafting itself, and
sometimes to a cold read: a subagent that reads the draft fresh, the way
your reader will. The agent may skip it. In the benchmark, Opus ran one in
12 of 30 sessions, and Sonnet in 1.

## Background

The skill grew out of personal writing rules that Ihor H. has used in his
Claude Code sessions for over three months. In October 2026, Claude measured
its own output under those rules: 784 chat replies and 63 documents from 50
sessions. The habits Ihor suspected, such as dropping the word *that*,
explained little. Two habits he hadn't suspected cost more. Phrases with no
verb, often after a colon, turned up in 3 to 4 of every 100 replies. Clauses
nested three deep turned up in about 2 of every 100 sentences. Both became
sentence traps in the skill: telegraphic style and center embedding.

The skill also draws on writing and reading research:

- **Garden-path sentences** (Bever, 1970). An early word invites a reading
  that the rest of the sentence overturns, as in *the horse raced past the
  barn fell*, so the reader has to parse it again.
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

Copyright © 2026 Ihor H.

- **CC BY 4.0** ([LICENSE-DOCS](LICENSE-DOCS)) covers the documentation:
  every file named `README.md`, wherever it sits, and everything in `docs/`
  and `bench/reports/`.
- **MIT** ([LICENSE](LICENSE)) covers everything else, including the code, the
  plugin and its skill, the rule file, and the benchmark's tasks and world.
