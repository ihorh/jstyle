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
3. Opus without the skill against Sonnet with it.

## Which Side Gets Which Sample

One side of each comparison is privileged: the stronger model, or the side
with the skill. The other side is disadvantaged.

- **The privileged side always shows sample 1.** Samples are independent
  draws, so sample 1 is a typical one, and no judgment picks it.
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

## Order and Labels

Each task labels its two excerpts A and B. The order comes from a seeded draw,
so it can be redrawn and checked:

```python
import random
r = random.Random("<run A folder> vs <run B folder>")
for task in tasks:
    print(task, "A=first" if r.random() < 0.5 else "A=second")
```

The key appears only in the last section.

## Layout

```
# <Side 1> vs <Side 2>, <what differs>

Metadata table: runs, model IDs, Claude Code version, inputs commit,
skill commit, samples, the sample rule.

What to look for: the three fronts, one line each.

## 01 README
One line: the task, its reader, the passage.
**A**, then the excerpt as a blockquote.
**B**, then the excerpt as a blockquote.

… one section per task …

## Key and Scores
Table: task, which side is A, sample shown, the writer's pick, one-line reason.
Stats: mean output tokens and seconds per task, from `make stats`.
Conclusion: a short paragraph.
```

Excerpts stack one above the other. GitHub table cells can't hold lists or
code blocks, and long text in a cell becomes a narrow column.

A report is named `<date>-<side 1>-vs-<side 2>.md`, and the repository README
links the latest one for each standing comparison.
