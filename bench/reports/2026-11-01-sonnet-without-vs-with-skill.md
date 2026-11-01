# Sonnet 5.5 Without the Skill vs With It

| | |
|---|---|
| Runs | Without the skill: `runs/2026-11-01-claude-sonnet-5-5`. With it: `runs/2026-11-01-claude-sonnet-5-5-2` |
| Model | `claude-sonnet-5-5`, default effort, on both sides |
| Claude Code | 2.1.309 on both sides |
| Runner | Without the skill: the earlier `claude -p` runner. With it: `claude plugin eval` with no user or project settings |
| Tools | Without the skill: `Read`, `Glob`, and `Grep`. With it: those, plus `Agent` and `Skill` |
| Inputs | `bench/world` and the task prompts are identical in both runs. The commits differ only in the eval tool's case files |
| Skill | `plugins/jstyle` at `8b88833` |
| Samples | 3 per task on each side |
| Sample shown | With the skill, the privileged side: its first session that loaded the skill, which is sample 1 except in task 05. Without it: the best of its 3, picked by the report's writer |

Each task shows the same passage from both sides, labeled A and B in a seeded
random order. Each task ends with a collapsed reveal, so you can judge the
pair first and check right after. The Key section at the end collects all ten.
The recipe is in [README.md](README.md).

The two sides ran through different runners, because the run without the skill
predates the switch to `claude plugin eval`. The prompts, the project files, and
the model are the same, and the side without the skill never used a subagent
in the Opus run either, so the missing `Agent` tool likely changed little. It
is still a difference between the sides.

The maintainer judged these pairs blind, before the key was shown, and those
picks are in the Scores section.

**What to look for:**

- **Correct.** Does every claim come from the project's files, or does some
  fact appear from nowhere?
- **Understood.** Could the task's reader act on this without opening another
  file or asking?
- **Parsed in one pass.** Did any sentence send you back to reread it?

## 01 README

The public README, for someone deciding whether to use the tool. Passage: from the title through the first example and the lines right after it. The side with the skill has no list near the top, so the recipe's first two list items are left out.

**A**

> # splitlane
>
> splitlane splits a large CSV file into smaller CSV files. Every output file starts with the input's header row, so each chunk can be loaded on its own. It's a command-line tool written in Python, and it uses only the standard library.
>
> ## Install
>
> splitlane is installed from a checkout:
>
> ```bash
> pip install .
> ```
>
> ## Usage
>
> ```bash
> splitlane data/export.csv --rows 50000 --out chunks
> ```
>
> This writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on. The last chunk holds whatever rows remain.

**B**

> # splitlane
>
> Split a large CSV file into smaller CSV files. Every chunk repeats the header row.
>
> ```bash
> splitlane data/export.csv --rows 50000 --out chunks
> ```
>
> ```
> chunks/part-0001.csv
> chunks/part-0002.csv
> ...
> ```
>
> It uses only the Python standard library and has no dependencies.

<details>
<summary>Reveal A and B</summary>

- **A:** With the skill, sample 1
- **B:** Without the skill, sample 3

</details>

## 02 Docstring

The docstring of `read_row()`, for a caller who won't read its body. Passage: every sentence about what happens when a row is truncated.

**A**

> ```
> Rows longer than `max_row_bytes` are cut short. The limit is measured in
> UTF-8 bytes, and it counts quote characters and newlines inside quotes. The
> returned text is cut at a character boundary, so it never exceeds the limit.
> The rest of that row is read and discarded up to the next newline, whether or
> not the newline is quoted. After a truncation the stream is therefore
> positioned at the start of the next line. The truncated text can end inside an
> open quote, so don't assume its quotes are balanced.
> […]
> - `(text, True)`: the row exceeded `max_row_bytes`, and `text` holds
>   only its first part.
> ```

**B**

> ```
> - `(text, True)`: the row exceeded `max_row_bytes`. `text` holds only the content read before the limit was passed. The rest of the row is discarded up to the next newline, whether or not that newline is inside quotes. Because of this, the next call may start mid-record if the discarded part contained a quoted newline. `text` may end inside an open quote.
> ```

<details>
<summary>Reveal A and B</summary>

- **A:** With the skill, sample 1
- **B:** Without the skill, sample 1

</details>

## 03 Email

devi's email asking Priya, who isn't technical, to decide on the 0.4.0 release. Passage: the sentences that state the decision, and the paragraph that describes the problem.

**A**

> splitlane 0.4.0 is ready, and I need your decision on whether to release it now or hold it. I recommend releasing now.
>
> […]
>
> **The one open problem (#57, Windows only)**
> If someone runs splitlane a second time into the same output folder, and one of the files from the first run is open in Excel, Windows won't let splitlane overwrite it. The tool stops partway through. The files written before that point are new, and the rest are still the old ones. The error message doesn't say which is which, so the person could end up with a mix of old and new data without realizing it.

**B**

> I need you to decide whether we ship splitlane 0.4.0 now or hold it until a Windows bug is fixed. I recommend shipping now.
>
> […]
>
> **The Windows problem (issue #57)**
> Suppose someone re-runs splitlane into a folder that already holds files from an earlier run, and one of those files is open in Excel. Windows won't let splitlane replace an open file. splitlane stops with an error that doesn't say which file caused it. By then it has already replaced the files before that one. The folder is left with a mix of new and old files, and the user can't tell which is which. This doesn't happen on Linux or macOS.

<details>
<summary>Reveal A and B</summary>

- **A:** Without the skill, sample 2
- **B:** With the skill, sample 1

</details>

## 04 Pitch

tomasz's comment on devi's `progress-bar` merge request, pitching a one-pass design. Passage: from the opening of the comment through the paragraph that states the proposal.

**A**

> Hi devi, thanks for the progress bar work. I have one suggestion to raise before this merges.
>
> **The concern:** the branch counts every row before splitting so it can show a percentage. That means reading the whole input twice. On our biggest exports I expect the first pass alone to take a noticeable while. I haven't timed it, so that's a guess, and I'll measure it if you'd like numbers.
>
> **Proposal:** drop the pre-count and report "rows processed" and chunks written instead of a percentage. That gives one pass over the input. `split_file()` already reads row by row, so the change should be confined to the CLI code in this branch. I'm happy to do that part.

**B**

> Nice work on the progress bar, Devi. Users do ask for it. I'd like to propose one change before this merges.
>
> The bar gets its percentage by counting all rows before splitting, so the input is read twice. I haven't timed it, but on our biggest exports the first pass alone takes a noticeable while before anything is written. `split_file()` already reads row by row, so one pass would be enough if we drop the pre-count.
>
> What I'd suggest is to replace the percentage with a running "rows processed" count and the number of chunks written. The change is all in this branch's CLI code, and `split_file()` stays as it is. The cost is that we lose the percentage and the ETA, and I know some users like those.

<details>
<summary>Reveal A and B</summary>

- **A:** Without the skill, sample 2
- **B:** With the skill, sample 1

</details>

## 05 Failure reply

The maintainer's reply to a user whose run failed. Passage: what went wrong, and what the reply says about the partial chunk. The side with the skill shows sample 2, because sample 1 didn't load the skill.

**A**

> Your CSV isn't UTF-8, and splitlane defaults to reading UTF-8. The `file` output reports ISO-8859 text, and the failing byte `0xe9` is `é` in Latin-1/Windows-1252. About 4 KB in, splitlane hit a name or city with an accent, couldn't decode it, and stopped with exit code 3 (the documented "cannot decode input" status).
>
> **Don't use `chunks/part-0001.csv`.** It was partly written before the error, so it has only 183 lines, not the 20,000 rows you asked for. splitlane doesn't clean up after a failed run. Delete the `chunks` directory, or at least that file, before re-running.

**B**

> Your export isn't UTF-8, and splitlane reads input as UTF-8 by default. The file is almost certainly Latin-1 or Windows-1252 (the byte `0xe9` is `é` in both). `file` reports it as ISO-8859, and the sample rows you pasted have only ASCII names. The first accented character is somewhere after the first 180 or so rows.
>
> When splitlane hit that byte, it stopped and exited with code 3, which is its encoding-error code. By then it had already written `chunks/part-0001.csv`, so that file is a partial chunk (183 lines, not 20,000 rows). It's not a usable result, so delete it.

<details>
<summary>Reveal A and B</summary>

- **A:** Without the skill, sample 3
- **B:** With the skill, sample 2

</details>

## 06 Decision record

The decision record for issue #42, for contributors who won't read the thread. Passage: the section that states the decision.

**A**

> `read_row()` tracks quotes, so a newline inside quotes stays in the row. The
> tracking is bounded:
>
> - If a row grows past `--max-row-bytes` (default 65536), the reader stops
>   and returns what it has, flagged as truncated.
> - It then skips ahead to the next newline and resumes reading rows from there.
> - The limit is in bytes, not lines. A legitimate note can have many lines, so
>   counting lines would reject valid data.
>
> Truncation is reported, not silent:
>
> - `read_row()` returns `(row, was_truncated)`. Library callers get the flag.
> - `split_file()` returns the count of truncated rows.
> - The CLI prints `warning: N row(s) longer than <limit> bytes were truncated`
>   to stderr at the end of a run. Callers who script around splitlane (the
>   billing and support teams do) should check for this message.

**B**

> `read_row()` tracks quotes, so a newline inside quotes stays in the row. The tracking is bounded by `--max-row-bytes` (default 65536):
>
> - When a row grows past the limit, the reader stops and returns the row cut at that point.
> - It then skips ahead to the next newline, whether or not that newline is inside quotes, and reading resumes from there.
> - The cut row is reported as truncated. `read_row()` returns `True` as the second element of its result, and the CLI prints the number of truncated rows at the end of a run.
>
> A legitimate multi-line field is far below the limit. A stray quote now damages a bounded amount of input instead of the rest of the file.

<details>
<summary>Reveal A and B</summary>

- **A:** Without the skill, sample 3
- **B:** With the skill, sample 1

</details>

## 07 Release notes

The 0.4.0 release notes, for users upgrading from 0.3.1. Passage: the entry about the renamed output files.

**A**

> **Output files are named differently.** Chunks are now written as `part-0001.csv`, `part-0002.csv`, and so on. In 0.3.1 they were `chunk_1.csv`, `chunk_2.csv`, and so on. The new names are zero-padded to four digits, so they sort correctly. Update any script, glob, or pipeline that looks for `chunk_*.csv`.

**B**

> **Output files are renamed.** Chunks are now `part-0001.csv`, `part-0002.csv`, and so on. They were `chunk_1.csv`, `chunk_2.csv`. Update any script or pipeline that looks for the old names. If you write to a directory that still holds chunks from 0.3.1, the old `chunk_*.csv` files stay there next to the new ones. Clear the directory first.

<details>
<summary>Reveal A and B</summary>

- **A:** Without the skill, sample 3
- **B:** With the skill, sample 1

</details>

## 08 README edit

An update to the README, so users learn how long rows are handled before they run into it. Passage: the first two paragraphs or list items the edit adds about long rows.

**A**

> A row longer than `--max-row-bytes` (measured in UTF-8 bytes) is not kept whole. splitlane cuts it at the limit, writes the shortened row to the chunk, and skips ahead to the next newline. The cut row is counted, and the rest of the file is processed normally.
>
> This limit also stops an unterminated quote from swallowing the rest of the file. Newlines inside quoted fields stay in the row, so legitimate multi-line fields are fine as long as the row stays under the limit. A stray quote damages one row instead of the whole file.

**B**

> A row longer than `--max-row-bytes` is cut off, not kept whole. The limit is
> measured in UTF-8 bytes. A quoted field that contains newlines is part of its
> row, so those bytes count too.
>
> When a row goes over the limit, splitlane:
>
> - writes the first `--max-row-bytes` bytes of the row to its chunk,
> - drops the rest of the row, up to the next newline, even if that newline is
>   inside quotes, and
> - carries on with the next row.

<details>
<summary>Reveal A and B</summary>

- **A:** Without the skill, sample 1
- **B:** With the skill, sample 1

</details>

## 09 Catch-up

The message that catches Sam up on tomasz's open follow-up to issue #42. Passage: the passage that describes the follow-up Sam takes over, without its heading.

**A**

> tomasz's comment on 2026-10-03 reads: "the skip after truncation goes to the next newline even if that newline is inside quotes. So in a bad case, the reader might resync in the middle of a real multi-line field. Probably rare. Not blocking."
>
> The skip loop is at `src/splitlane/split.py:24-29`. It reads characters until the first `\n` and ignores quotes. I checked it against the code and it behaves as tomasz described. Nobody has written a fix, a test, or a reproduction.

**B**

> After truncation, the skip goes to the next `\n` even if that newline is inside quotes. It's at `src/splitlane/split.py:24-28`, and the comment there says "quoted or not". If a stray quote forces a truncation, the reader may resume in the middle of a real multi-line field.
>
> My reading of the code, which I haven't run: the next `read_row()` call starts with `in_quotes = False`. The closing quote of that half-read field would then flip it to "inside quotes". The next row's newline could then be swallowed until another quote shows up, or until the limit is hit again. So one bad quote could damage more than one row. It would still be bounded, not a swallowed file.
>
> tomasz called it probably rare and not blocking. Nobody has measured how often it happens, and nobody has reproduced it or written a test for it. No fix has been proposed or agreed.

<details>
<summary>Reveal A and B</summary>

- **A:** With the skill, sample 1
- **B:** Without the skill, sample 3

</details>

## 10 Agent rules

The `AGENTS.md` that coding agents load in every session. Passage: the rule about output file names, without its heading.

**A**

> Never change the names of output files. The exception is a maintainer asking for it, as with the 0.4.0 rename. When you rename a file at a maintainer's request, also update the README and the changelog.

**B**

> - Never change output file names.
> - Exception: a maintainer explicitly asks for it, as with the 0.4.0 rename. In that case, also update the README and the changelog.

<details>
<summary>Reveal A and B</summary>

- **A:** With the skill, sample 1
- **B:** Without the skill, sample 1

</details>

## Key

<details>
<summary>Which side is A and which is B, per task</summary>

The order comes from `random.Random("runs/2026-11-01-claude-sonnet-5-5 vs runs/2026-11-01-claude-sonnet-5-5-2")`,
drawn once per task, with "first" meaning the side without the skill.

| Task | A | B |
|---|---|---|
| 01 README | With the skill, sample 1 | Without the skill, sample 3 |
| 02 Docstring | With the skill, sample 1 | Without the skill, sample 1 |
| 03 Email | Without the skill, sample 2 | With the skill, sample 1 |
| 04 Pitch | Without the skill, sample 2 | With the skill, sample 1 |
| 05 Failure reply | Without the skill, sample 3 | With the skill, sample 2 |
| 06 Decision record | Without the skill, sample 3 | With the skill, sample 1 |
| 07 Release notes | Without the skill, sample 3 | With the skill, sample 1 |
| 08 README edit | Without the skill, sample 1 | With the skill, sample 1 |
| 09 Catch-up | With the skill, sample 1 | Without the skill, sample 3 |
| 10 Agent rules | With the skill, sample 1 | Without the skill, sample 1 |

</details>

## Scores

### The Maintainer's Picks

Made blind, from the excerpts alone. The reasons are the maintainer's own,
lightly edited for spelling.

| Task | Pick | Side | Reason |
|---|---|---|---|
| 01 README | A | with the skill | Both are sloppy for a public README, but A includes more details. |
| 02 Docstring | A | with the skill | No reason given blind, beyond asking whether B's one long line was a bug. After the key: even if B is more correct, no one will read it and learn from it, and A has a chance of being read. |
| 03 Email | B | with the skill | B's first sentence already explains more than A's, so the model judged what was important to put in the first sentence. |
| 04 Pitch | A | without the skill | Sonnet is more polite than Opus was. A is marginally better. |
| 05 Failure reply | B | with the skill | Both read like Linus Torvalds wrote them, but B is marginally better. |
| 06 Decision record | B | with the skill | B is easier to understand even at first glance. A also seems correct and detailed, but it's harder to read. |
| 07 Release notes | A | without the skill | Judged by the first line alone. |
| 08 README edit | B | with the skill | The parentheses in A's first sentence broke the reading flow. Overall B is better. |
| 09 Catch-up | B | without the skill | A opened with tomasz's comment and its date, and lost me at once. In B I get what I need from the first line. |
| 10 Agent rules | B | without the skill | Both are good, and it's a matter of taste. I prefer the structure here. |

Tally: with the skill 6, without it 4.

### The Writer's Picks

Made by the report's writer, after the key was known, so they aren't blind.

| Task | Pick | Reason |
|---|---|---|
| 01 README | With the skill | Says each chunk can be loaded on its own, and that the last chunk holds the rows that remain |
| 02 Docstring | Without it | Only this side warns that the next call may start in the middle of a record. The other says the stream sits "at the start of the next line", which can be inside a quoted field |
| 03 Email | With the skill | Its first sentence names both choices and what the wait is for |
| 04 Pitch | Even | The same content, in bold-labeled paragraphs on one side and plain paragraphs on the other |
| 05 Failure reply | Even | The same facts. Both say the partial chunk has 183 lines and shouldn't be used |
| 06 Decision record | Without it | Adds why the limit counts bytes rather than lines, and that scripts should check for the warning |
| 07 Release notes | With the skill | Only this side says the old `chunk_*.csv` files stay next to the new ones |
| 08 README edit | With the skill | States the limit's unit without a parenthesis, and lists what happens to the row as steps |
| 09 Catch-up | Without it | Works out from the code that one bad quote can damage more than one row, and says it hasn't run it |
| 10 Agent rules | Even | The same rule and exception, as prose on one side and bullets on the other |

Tally: with the skill 4, without it 3, even 3.

### Cost

Mean tokens per session, from `lib/stats.sh`. Output includes thinking, and
input counts cached tokens too. Cold reads counts the skill sessions out of 3
that started a subagent. The one cold read, in task 03, isn't broken out
here.

| Task | Without: output | With: output | Without: input | With: input | Without: s | With: s | Cold reads |
|---|---|---|---|---|---|---|---|
| 01 README | 2670 | 2638 | 31027 | 51437 | 20 | 21 | 0 of 3 |
| 02 Docstring | 1139 | 1239 | 16186 | 30100 | 11 | 12 | 0 of 3 |
| 03 Email | 2371 | 1993 | 35645 | 59101 | 20 | 17 | 1 of 3 |
| 04 Pitch | 647 | 706 | 11827 | 24941 | 6 | 8 | 0 of 3 |
| 05 Failure reply | 1267 | 1597 | 25238 | 45082 | 12 | 15 | 0 of 3 |
| 06 Decision record | 3055 | 3727 | 38230 | 65222 | 22 | 27 | 0 of 3 |
| 07 Release notes | 1585 | 2349 | 23940 | 71710 | 13 | 20 | 0 of 3 |
| 08 README edit | 1275 | 1320 | 22595 | 44305 | 10 | 12 | 0 of 3 |
| 09 Catch-up | 2072 | 2296 | 34438 | 51005 | 16 | 18 | 0 of 3 |
| 10 Agent rules | 851 | 1277 | 11716 | 30046 | 8 | 11 | 0 of 3 |

The run without the skill cost $1.31 for 30 sessions at list price, and the
run with it $2.35, about 1.8 times as much. A session with the skill took
about 16 seconds against 14, and wrote about 220 more output tokens. Most of
the extra cost is input: a session with the skill read about 22,000 more input
tokens, likely the skill's own text carried through every turn. The skill
loaded in 29 of its 30 sessions.

**Conclusion.** Judged blind, the maintainer preferred the side with the skill
in 6 of 10 tasks, against 8 of 10 for Opus. Sonnet ran a cold read in 1 of 30
sessions, where Opus ran one in 12, so Sonnet followed the skill's wording
rules but mostly skipped the step that checks the text against a reader. The
docstring shows the trade both ways: the maintainer picked the version with
the skill for readability, and the writer picked the other for the one
warning a caller needs. The skill costs about 1.8 times as much on Sonnet too,
mostly in input tokens. One reader, one sample per side, and two runners make
this a first signal, not a measurement.
