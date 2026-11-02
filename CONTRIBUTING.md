# Contributing

How changes to jstyle are made, checked, and released. For what the plugin
does, see the [README](README.md). To tell us how the skill changed your prose,
use the [feedback
form](https://github.com/ihorh/jstyle/issues/new?template=feedback.yml)
instead.

## Layout

- `plugins/jstyle/` is the plugin: `skills/write/SKILL.md` (the skill),
  `.claude-plugin/plugin.json` (its manifest and version), its own
  `README.md`, and `icon.png` for a directory listing.
- `.claude-plugin/marketplace.json` makes this repository a marketplace with
  one plugin.
- `rules/` holds the punctuation rule file, which isn't part of the plugin.
- `docs/` holds longer notes, such as how the skill was written for its models.
- `bench/` is the benchmark: `run.sh`, `tasks/`, the `world/` each session
  starts in, `runs/`, and `reports/`.
- `.github/readme/` holds the README's images.

## Making a Change

- **One change per commit.** The subject says what changed, in sentence case,
  such as "Using It: put the commands on their own lines".
- **Validate before committing** a change to the plugin or the marketplace:

  ```
  claude plugin validate .
  claude plugin validate plugins/jstyle
  ```

- **README facts come from the docs or a run, never from memory.** For Claude
  Code's own behaviour, such as installing or toggling plugins, link its docs
  rather than restating them.
- **A skill example never comes from `bench/world/` or `bench/tasks/`.** A
  benchmark session that finds its task's answer in the skill copies it.
- **Images** in `.github/readme/` are committed without embedded metadata,
  such as a C2PA manifest from a design tool.

## Versions and the Changelog

The version lives in `plugins/jstyle/.claude-plugin/plugin.json`. Installed
users stay on their version until they update, so a change reaches them only
with a new version.

- **Patch** (0.3.0 to 0.3.1): wording or metadata, with no change meant in how
  the agent behaves.
- **Minor** (0.3.0 to 0.4.0): the agent writes or behaves differently.
- **Major**: something users rely on is removed or renamed, such as the skill
  or its command.

Bump the version and add a [CHANGELOG.md](CHANGELOG.md) entry in the same
commit. A release on GitHub, if one is made, uses that entry as its note.

## Keeping Text in Sync

Some text appears in more than one place. When one copy changes, update the
others in the same commit.

- **The tagline**, word for word, is the README header's subtitle and the
  marketplace's top-level description, and opens the GitHub repository
  description.
- **The plugin description** is the same in `plugin.json` and in the plugin's
  entry in `marketplace.json`.
- **The plugin's README** restates parts of the main README's Using It, How It
  Writes, Cold Reads, Disclaimer, and License sections. Its License section covers
  only the plugin folder.

## Checking Prose

The README, the plugin README, and the skill get a cold read before they're
committed: a reader with none of the writer's context reads the text and lists
what it had to reread or couldn't follow. An agent with jstyle loaded runs one
as the skill's Cold Read section describes. To run one by hand, start a
session that sees only the text, from an empty directory:

```
claude -p --setting-sources local --tools "" --model sonnet < prompt.txt
```

Run the same prompt with `--model opus` too. The prompt gives the text and one line on
who it's for, and asks for questions, not rewrites. Readers tend to ask for
thresholds and exact rules where the text leaves room for judgment on purpose,
so weigh those questions before acting on them.

## The Benchmark

`bench/run.sh MODEL` runs every task with and without the skill, through
`claude plugin eval`. MODEL is a full model ID, such as `claude-opus-5-5`. The
script's header lists cheaper runs and what each run writes.

[bench/reports/README.md](bench/reports/README.md) is the recipe for a report,
and lists the standing comparisons to rerun whenever a run they depend on
changes. The root `pyrightconfig.json` tells the type checker to skip
`bench/world/`, a fictional project that isn't meant to type-check. It stays
at the root, because a config inside `bench/world/` would be copied into every
benchmark session.

## Licenses

A contribution falls under the license of the file it changes. CC BY 4.0
covers every `README.md` and everything in `docs/` and `bench/reports/`. MIT
covers the rest. See [License](README.md#license).
