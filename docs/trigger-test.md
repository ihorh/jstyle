# Trigger Test

Whether the skill loads on its own in Claude Code, checked on 1 November 2026
with Claude Code 2.1.309.

## Setup

Each prompt ran once on Opus 5.5 and once on Sonnet 5.5, in a fresh
`claude -p` session started in a copy of `bench/world/`. The session loaded
the plugin with `--plugin-dir`, had the tools `Read`, `Glob`, `Grep`, and
`Skill`, and no user or project settings. A run counts as a load when the
session called the `Skill` tool with `jstyle:write`.

## Results

| Prompt | Kind | Opus 5.5 | Sonnet 5.5 |
|---|---|---|---|
| Write a short README section explaining how to install and run it | draft | loaded | loaded |
| Draft an email to the team announcing the release slip | draft | loaded | loaded |
| Add a numpy-style docstring to the split function | draft | loaded | loaded |
| Write release notes for the changes in release.diff | draft | loaded | loaded |
| Reply to issue 42 for me, I'll paste it on GitHub | draft | loaded | skipped |
| What does split.py do when a row is longer than the chunk size? | chat | off | off |
| Is the streaming proposal a good idea? | chat | off | off |

The skill loaded for 9 of the 10 drafting runs and stayed off for all 4 chat
runs. The one skip still produced a reasonable reply.

## Limits

One run per prompt and model, so this shows the skill's description routes
well, not how often it fails. A session without the `Skill` tool sees the
skill listed but can't load it.
