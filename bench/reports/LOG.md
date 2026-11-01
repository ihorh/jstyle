# Report Log

Each report keeps its verdict at the end, after the excerpts, so the reader
judges first. This log gives each report's outcome at a glance, newest first.
The reports themselves have the excerpts, the reasons for each pick, and the
full cost tables.

## 2026-11-01: Sonnet 5.5 Without the Skill vs With It

[Report](2026-11-01-sonnet-without-vs-with-skill.md) ·
runs `runs/2026-11-01-claude-sonnet-5-5`, `runs/2026-11-01-claude-sonnet-5-5-2`

- **Tested.** Sonnet 5.5 on all 10 tasks, 3 sessions each with the skill and 3
  without. The side without the skill came from the earlier `claude -p`
  runner with read-only tools, and the side with it from `claude plugin eval`.
  The prompts and project files are the same.
- **Cost and time.** The side with the skill cost about 1.8 times as much,
  $2.35 against $1.31 for 30 sessions each, and took about 16 seconds per
  session against 14. The extra is mostly input tokens, not writing.
- **The human's blind picks.** With the skill in 6 of 10 tasks. Without it won
  the pitch, the release notes, the catch-up, and the agent rules.
- **The writer's picks,** made after the key was known: with the skill 4,
  without it 3, even 3.
- **Quirks.** Sonnet ran a cold read in only 1 of 30 sessions, against 12 for
  Opus. In the docstring, the maintainer picked the side with the skill for
  readability, and the writer picked the other for the one warning a caller
  needs.

## 2026-11-01: Opus 5.5 Without the Skill vs With It

[Report](2026-11-01-opus-without-vs-with-skill.md) ·
run `runs/2026-11-01-claude-opus-5-5-2`

- **Tested.** Opus 5.5 on all 10 tasks, 3 sessions each with the skill and 3
  without, through `claude plugin eval`. Both sides had the `Agent` tool, so
  the skill could run its cold read.
- **Cost and time.** The side with the skill cost about 1.8 times as much,
  $6.81 against $3.84 at list price for 30 sessions each, and took about twice
  as long per session. Most of the extra was the main session's own writing,
  not the cold-read reader.
- **The human's blind picks.** With the skill in 8 of 10 tasks. Without it won
  the docstring and the decision record.
- **The writer's picks,** made after the key was known: with the skill 6,
  without it 3, even 1.
- **Quirks.** The two tasks the side without the skill won are the only two
  where no skill session ran a cold read. The skill loaded in 29 of its 30
  sessions, and 12 of them ran a cold read.

## 2026-11-01: Sonnet 5.5 vs Opus 5.5, Both Without the Skill

[Report](2026-11-01-sonnet-vs-opus-baseline.md) ·
runs `runs/2026-11-01-claude-opus-5-5`, `runs/2026-11-01-claude-sonnet-5-5`

- **Tested.** Both models on all 10 tasks without the skill, 3 sessions each,
  through the earlier Makefile runner with read-only tools.
- **Cost and time.** Sonnet cost about $1.31 for 30 sessions and Opus about
  $3.52, and Sonnet took about half the time per session.
- **The human's blind picks.** Not judged blind.
- **The writer's picks:** Opus 5, Sonnet 1, tie 4.
- **Quirks.** Sonnet's one win came from Opus having devi report a finding
  that the project's notes never contain. Neither model showed much of the
  compression the skill targets, so invented framing looked like the first
  failure to target.
