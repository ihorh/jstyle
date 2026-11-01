# Benchmark Reports

A report sets excerpts from two runs side by side, so a person can judge them.
It opens with the excerpts and keeps the writer's own scores for the end, so
the reader's judgment comes first.

This file is the recipe. Follow it as written whoever writes the report, a
person or a model. The writer picks and arranges excerpts, and interprets
nothing until the last section.

## Standing Comparisons

Rerun these whenever a run they depend on changes:

1. Sonnet against Opus, both without the skill.
2. Opus without the skill against Opus with it.
3. Sonnet without the skill against Sonnet with it.

## Which Side Gets Which Sample

One side of each comparison is privileged: the stronger model, or the side
with the skill. The other side is disadvantaged.

- **The privileged side always shows sample 1.** Samples are independent
  draws, so sample 1 is a typical one, and no judgment picks it. When the
  privileged side is the side with the skill and sample 1 didn't load it, show
  the first sample that did. The report says so for that task.
- **The disadvantaged side shows its best sample,** chosen by the writer for
  the passage below. The report names the sample used.

This tilts every pair against the privileged side. A preference for it that
survives the tilt is worth more.

## Which Passage to Excerpt

Each task shows the same passage from both sides, cut by the same rule. An
excerpt runs about 60 to 200 words. Cut whole sentences, and mark a gap with
`[…]`.

| Task | Passage |
|---|---|
| 01 README | From the title through the first two items of the first list |
| 02 Docstring | Every sentence about what happens when a row is truncated |
| 03 Email | The sentences that state the decision, and the paragraph that describes the problem |
| 04 Pitch | From the opening through the paragraph that states the proposal |
| 05 Failure reply | What went wrong, and what the reply says about the partial chunk |
| 06 Decision record | The section that states the decision |
| 07 Release notes | The entry about the renamed output files |
| 08 README edit | The first two paragraphs or list items the edit adds about long rows |
| 09 Catch-up | The passage that describes the follow-up Sam takes over |
| 10 Agent rules | The rule about output file names |

## What to Look For

Every report opens with this list, as written, so a reader judges each pair by
the same questions:

- **Holds attention.** Read from the top. Where did you first stumble, and
  how far in was it?
- **Correct.** Does every claim come from the project's files, or does some
  fact appear from nowhere?
- **Understood.** Could the task's reader act on this without opening another
  file or asking?
- **Parsed in one pass.** Did any sentence send you back to reread it?

The first three reports, from 2026-11-01, list only the last three items.

## Order and Labels

Each task labels its two excerpts A and B. The order comes from a seeded draw,
so it can be redrawn and checked:

```python
import random
r = random.Random("<run A folder> vs <run B folder>")
for task in tasks:
    print(task, "A=first" if r.random() < 0.5 else "A=second")
```

Each task ends with a collapsed `<details>` block that reveals its A and B, so
the reader judges the pair, then checks at once. A Key section after the tasks
collects all ten in one collapsed table.

## Layout

```
# <Side 1> vs <Side 2>, <what differs>

Metadata table: runs, model IDs, Claude Code version, inputs commit,
skill commit, samples, the sample rule.

What to look for: the list under What to Look For, as written.

## 01 README
One line: the task, its reader, the passage.
**A**, then the excerpt as a blockquote.
**B**, then the excerpt as a blockquote.
A collapsed <details> reveal, with A and B on separate lines.

… one section per task …

## Key
The A/B table inside <details>, so GitHub shows it collapsed until clicked.

## Scores
Table: task, the writer's pick, one-line reason.
Stats: mean output tokens and seconds per task, from `lib/stats.sh`.
Conclusion: a short paragraph.
```

Excerpts stack one above the other. GitHub table cells can't hold lists or
code blocks, and long text in a cell becomes a narrow column.

A report is named `<date>-<side 1>-vs-<side 2>.md`, and the repository README
links the latest one for each standing comparison.

Each new report also gets an entry at the top of [LOG.md](LOG.md): what was
tested, the cost and time difference, the human's blind picks, the writer's
picks, and a quirk or two. Keep each entry to a few lines.
