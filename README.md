# jstyle

> [!NOTE]
> - **One skill,** `/jstyle:write`, in a Claude Code plugin. The agent loads
>   it on its own when it drafts text for a reader outside the conversation.
> - **Judged blind.** In the first benchmark, the maintainer preferred Opus 5.5
>   with the skill in 8 of 10 writing tasks, without knowing which side was
>   which. See the [report log](bench/reports/LOG.md).
> - **Costs more.** A session with the skill cost about 1.8 times as much and
>   took about twice as long.
> - **Early.** Tested in English, with Claude models, by one judge so far.

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

Two prompts, each run once on Opus 5.5 without the skill and once with it.
These are first attempts, cut to the passage where they differ most.
[bench/examples/RESULTS.md](bench/examples/RESULTS.md) has them in full, with
the prompts and the notes the agent wrote from.

**A water shutoff notice** from a residents' committee to its tenants.

Without the skill:

> On **Wednesday 18 November**, the water will be turned off for the whole
> building **from 9:00**. This includes **hot water**. Heating is on a separate
> circuit and will stay on.
>
> **Why:** Brightwater Plumbing is replacing the main water valve in the
> basement. The old valve leaked in October and flooded the basement storage,
> and our insurer wants it replaced before the policy is renewed in December.

With the skill:

> On Wednesday 18 November, Brightwater Plumbing will replace the main water
> valve in the basement. The water will go off for the whole building at 9 am.
> Hot water will go off too, because the boiler has to be switched off while
> the valve is out. The heating is on a separate circuit and will stay on.

**A pitch for this skill,** one paragraph written from this README.

Without the skill:

> In the first blind benchmark, the maintainer preferred Opus 5.5's writing
> with the skill in 8 of 10 tasks. The project is early. It has been tested
> only in English with Claude models, and a session with it costs about 1.8
> times as much and takes about twice as long.

With the skill:

> In the first benchmark, the maintainer compared Opus 5.5 with and without
> the skill, without knowing which output was which, and preferred the one
> with the skill in 8 of 10 writing tasks. That's one judge so far, and a
> session with the skill costs about 1.8 times as much and takes about twice
> as long.

Neither version of either text invented a fact.

## Install

In a Claude Code terminal session, version 2.1.275 or later, run this,
confirm adding the marketplace, and choose a scope:

```
/plugin install jstyle --marketplace ihorh/jstyle
```

`/plugins` opens the same plugin manager in the VS Code extension, and the
desktop app has an **Add plugins** button under **+** next to the prompt box.
A plugin you install in one of the three is available in the others on the
same computer. [Install and manage
plugins](https://code.claude.com/docs/en/discover-plugins) in the Claude Code
docs covers the other ways to install, scopes, and uninstalling.

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

Call it before you ask for a draft:

```
/jstyle:write
```

You can also just ask. In Claude Code the agent loads the skill on its own
when it drafts text for someone outside the conversation, such as an email or
a README, and leaves it off for ordinary chat replies. It also loads when you
ask for edits, or for a review that proposes new wording. It stays off for a
review that only gives feedback, such as a proofread or a verdict on whether a
text is ready to send. Other harnesses that support skills will likely route
it the same way, but we haven't tested them.
[docs/trigger-test.md](docs/trigger-test.md) has the test behind this.

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

## Turn It Off and On

To compare writing with and without the skill, turn it off and on again
without uninstalling:

- **In a terminal session,** run `/plugin`, and on the **Installed** tab press
  **Space** on `jstyle`.
- **In VS Code,** type `/plugins` and use the toggle next to `jstyle`.
- **In the desktop app,** click **+**, then **Plugins**, then **Manage
  plugins**.

Start a new session after each change. A skill that already loaded stays in
the conversation, so an open session can't show writing without it.

In the terminal and in VS Code, a change also reaches the open session without
a restart. In the terminal, when reloading the plugins would invalidate the
prompt cache, Claude Code warns you and leaves the change pending, and
`/reload-plugins --force` applies it anyway. [Install and manage
plugins](https://code.claude.com/docs/en/discover-plugins) lists the other ways
to turn a plugin off and on, including from your shell.

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

## What It Asks For

The skill puts correct facts and a clear idea ahead of brevity. It works on
four levels:

- **Facts.** The agent lists its facts with their sources before writing any
  prose, and marks the conclusions it drew itself as its own. The list stays
  in its working notes, and the text cites a source only where the reader
  needs one.
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
| Opus 5.5 without the skill vs Sonnet 5.5 with it | not yet run |

## Background

The skill grew out of personal writing rules that Ihor H. has used in his
Claude Code sessions for over three months. In October 2026, Claude measured
its own output under those rules: 784 chat replies and 63 documents from 50
sessions. The habits Ihor suspected, such as dropping the word *that*,
explained little. Two habits he hadn't suspected cost more. Phrases with no
verb, often after a colon, turned up in 3 to 4 of every 100 replies. Clauses
nested three deep turned up in about 2 of every 100 sentences. These findings
are why the skill targets compression.

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

Copyright © 2026 Ihor H.

- **CC BY 4.0** ([LICENSE-DOCS](LICENSE-DOCS)) covers the documentation:
  every file named `README.md`, wherever it sits, and everything in `docs/`
  and `bench/reports/`.
- **MIT** ([LICENSE](LICENSE)) covers everything else, including the code, the
  plugin and its skill, the rule file, and the benchmark's tasks and world.
