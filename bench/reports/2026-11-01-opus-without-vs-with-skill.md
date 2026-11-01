# Opus 5.5 Without the Skill vs With It

| | |
|---|---|
| Run | `runs/2026-11-01-claude-opus-5-5-2`, both sides in one run |
| Model | `claude-opus-5-5`, default effort, on both sides |
| Claude Code | 2.1.309, through `claude plugin eval` with no user or project settings |
| Tools | `Read`, `Glob`, `Grep`, `Agent`, and `Skill` on both sides |
| Inputs | `bench/world` and `bench/tasks` at `e4cc047` |
| Skill | `plugins/jstyle` at `8b88833` |
| Samples | 3 per task on each side |
| Sample shown | With the skill, the privileged side: sample 1. Without it: the best of its 3, picked by the report's writer |

Each task shows the same passage from both sides, labeled A and B in a seeded
random order. Each task ends with a collapsed reveal, so you can judge the
pair first and check right after. The Key section at the end collects all ten.
The recipe is in [README.md](README.md).

The maintainer judged these pairs blind, before the key was shown, and those
picks are in the Scores section.

**What to look for:**

- **Correct.** Does every claim come from the project's files, or does some
  fact appear from nowhere?
- **Understood.** Could the task's reader act on this without opening another
  file or asking?
- **Parsed in one pass.** Did any sentence send you back to reread it?

## 01 README

The public README, for someone deciding whether to use the tool. Passage: from the title through the first example and the lines right after it. The recipe asks for the first two items of the first list, but in this run that list sits about 60 lines down.

**A**

> # splitlane
>
> splitlane splits a large CSV file into smaller files. Each file holds a fixed number of rows, and each starts with the input's header row. You can use it as a command-line tool or as a Python library. It uses only the Python standard library.
>
> ```bash
> splitlane data/export.csv --rows 50000 --out chunks
> ```
>
> This command writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on. Every file except the last holds 50,000 data rows plus the header.
>
>

**B**

> # splitlane
>
> splitlane splits a large CSV file into smaller files. Every output file starts with the input's header row, so you can import or process each one on its own.
>
> ```bash
> splitlane data/export.csv --rows 50000 --out chunks
> ```
>
> ```
> chunks/part-0001.csv
> chunks/part-0002.csv
> chunks/part-0003.csv
> ...
> ```
>
> It needs only the Python standard library. It reads the input once, one row at a time, so memory use stays flat even on very large exports.
>
>

<details>
<summary>Reveal A and B</summary>

- **A:** With the skill, sample 1
- **B:** Without the skill, sample 3

</details>

## 02 Docstring

The docstring of `read_row()`, for a caller who won't read its body. Passage: every sentence about what happens when a row is truncated.

**A**

> ```
> - ``(text, True)``: the row was longer than ``max_row_bytes``. ``text``
>   holds as many whole characters from the start of the row as fit in
>   the limit. The function discards the rest of the input up to the
>   next newline.
> […]
> Note:
>     When a row is too long, the function discards input up to the next
>     newline even if that newline is inside a quoted field. If the cut
>     falls inside a multi-line quoted field, the next call starts partway
>     through that field. Rows read after that point may be split in the
>     wrong places until the quotes line up again.
> ```

**B**

> ```
> - ``(row, True)`` when the record was longer than ``max_row_bytes``.
>   ``row`` is the first ``max_row_bytes`` bytes or fewer, and it can
>   end inside a quoted field.
> […]
> Truncation:
>     After truncating a row, the rest of the input is discarded up to and
>     including the next newline, *whether or not that newline is inside
>     quotes*. If the oversized record has a quoted field with an embedded
>     newline after the cut point, the text after that newline is returned
>     by the next call as if it were a new row. Callers that need correct
>     record boundaries should treat rows that follow a truncated row as
>     unreliable, or set ``max_row_bytes`` high enough that truncation
>     does not happen.
> ```

<details>
<summary>Reveal A and B</summary>

- **A:** With the skill, sample 1
- **B:** Without the skill, sample 1

</details>

## 03 Email

devi's email asking Priya, who isn't technical, to decide on the 0.4.0 release. Passage: the sentences that state the decision, and the paragraph that describes the problem.

**A**

> 0.4.0 is ready apart from one problem. I need you to decide whether we ship it now or wait until that problem is fixed.
>
> […]
>
> **The problem**
>
> On Windows, splitlane crashes if someone has one of the files from an earlier run open in Excel when it tries to replace that file. By then it has already replaced the files before that one, and the error message doesn't say how far it got. The person ends up with a folder that mixes new files with old ones, and no easy way to tell which is which.

**B**

> The 0.4.0 release of splitlane is ready except for one problem. I need you to decide whether we ship it now or wait.
>
> […]
>
> **The problem**
>
> On Windows only: suppose someone runs splitlane, opens one of the output files in Excel, and then runs splitlane again while it's still open. splitlane stops partway through. Some files are new, some are left over from the earlier run, and nothing tells the user which is which. They could go on to use a mix of old and new data without knowing.

<details>
<summary>Reveal A and B</summary>

- **A:** With the skill, sample 1
- **B:** Without the skill, sample 1

</details>

## 04 Pitch

tomasz's comment on devi's `progress-bar` merge request, pitching a one-pass design. Passage: from the opening of the comment through the paragraph that states the proposal.

**A**

> Hey devi, before this merges I'd like to suggest a change to how the progress is computed. I'm not trying to block the branch.
>
> Right now the branch counts every row up front so it can show a percentage, which means we read the whole input twice. On our biggest exports that first counting pass takes a noticeable amount of time on its own. I'll be honest that I haven't timed it, so I can't give you a number yet. I can measure it on one of the large exports if that would help.
>
> **My suggestion:** drop the pre-count and show rows processed and chunks written as we go, instead of a percentage. That gets us back to a single pass. `split_file()` already reads row by row, so this would only touch the CLI side of your branch. The splitting logic stays as it is.

**B**

> Hi devi, I'd like to suggest a change before this merges.
>
> To show a percentage, the branch counts every row first and then splits, so splitlane reads the whole input twice. On our biggest exports the counting pass alone takes a noticeable while. I haven't timed it yet, but I can if you'd like numbers first.
>
> My suggestion is to drop the pre-count and show rows processed and chunks written instead of a percentage. That way splitlane reads the input once. `split_file()` already reads row by row, so as far as I can tell the change is all in the branch's CLI code.

<details>
<summary>Reveal A and B</summary>

- **A:** Without the skill, sample 3
- **B:** With the skill, sample 1

</details>

## 05 Failure reply

The maintainer's reply to a user whose run failed. Passage: what went wrong, and what the reply says about the partial chunk.

**A**

> **What went wrong**
>
> Your export isn't UTF-8. `file` reports it as `ISO-8859 text` (Latin-1), and splitlane reads input as UTF-8 unless you tell it otherwise. Byte `0xe9` is `é` in Latin-1, so the first name or city with an accent stopped the run. Exit status 3 means splitlane couldn't decode the input.
>
> **About `chunks/part-0001.csv`**
>
> splitlane writes rows as it reads them. It doesn't clean up when it stops early, so the file it was writing stays on disk. `part-0001.csv` has the header plus the 182 rows before the bad byte, which is fewer than the 20000 you asked for. Don't use it. That's a rough edge on our side, and we should either remove the partial output or say clearly that it's incomplete.

**B**

> Your export isn't UTF-8, and splitlane reads its input as UTF-8 unless you tell it otherwise. `file` says the CSV is ISO-8859 text. That's a family of encodings, but the most likely member is Latin-1 (ISO-8859-1). In Latin-1 the byte in the error, 0xe9, is `é`, so a name or city in the file has an accent. Exit status 3 is splitlane's code for "couldn't decode the input."
>
> […]
>
> The `chunks/part-0001.csv` left over from the failed run holds only the rows splitlane got through before the error, so don't use it. The new run would overwrite that file anyway. Clearing the directory first just means every file in it comes from the run that worked.

<details>
<summary>Reveal A and B</summary>

- **A:** Without the skill, sample 3
- **B:** With the skill, sample 1

</details>

## 06 Decision record

The decision record for issue #42, for contributors who won't read the thread. Passage: the section that states the decision.

**A**

> `read_row()` tracks quotes, so a newline inside a quoted field stays in the
> field. This matches RFC 4180 and the way spreadsheets read CSV.
>
> To stop a stray quote from swallowing the file, the existing `--max-row-bytes`
> limit also bounds quoted fields. The default is 65536 bytes. When a row grows
> past the limit, `read_row()`:
>
> 1. stops and returns what it has read so far as the row,
> 2. skips the input up to the next newline, or to the end of the input,
> 3. marks the row as truncated.
>
> A real multi-line note stays far below the limit. A stray quote reaches it,
> damages one row, and the reader picks up again at the next line.
>
> Truncation is never silent. `read_row()` returns a `(row, truncated)` pair, and
> `split_file()` returns the number of truncated rows. When that number is not
> zero, the CLI prints this warning to stderr at the end of the run:
>
> ```
> splitlane: warning: N row(s) longer than M bytes were truncated
> ```
>
> […]

**B**

> 1. **Track quotes.** `read_row()` toggles an `in_quotes` state on every `"`. A `\n` ends the row only when it is outside quotes, so quoted newlines stay in the field, as RFC 4180 specifies and spreadsheets do.
>
> 2. **Bound every row with `--max-row-bytes`** (default 65536, measured as UTF-8 bytes). If a row grows past the limit, the reader:
>    - stops and keeps what it has read so far as the row,
>    - throws away input up to the next `\n` (or the end of input), and
>    - marks the row as truncated.
>
>    A legitimate multi-line field stays far below the limit. A stray quote reaches the limit, damages that one row, and the reader picks up again on the next line. The worst case is one damaged row, not a swallowed file.
>
> 3. **Never truncate silently.**
>    - Library: `read_row()` returns `(row, truncated)`. `split_file()` returns `(written_paths, truncated_count)`.
>    - CLI: at the end of a run, if any rows were truncated, it prints this to stderr:
>      `splitlane: warning: N row(s) longer than M bytes were truncated`.
>      The exit status stays 0. Callers who need to catch truncation should look for this warning. The billing and support analytics scripts do.

<details>
<summary>Reveal A and B</summary>

- **A:** With the skill, sample 1
- **B:** Without the skill, sample 1

</details>

## 07 Release notes

The 0.4.0 release notes, for users upgrading from 0.3.1. Passage: the entry about the renamed output files, without its heading, since heading style differed between the sides.

**A**

> Chunk files are now called `part-0001.csv`, `part-0002.csv`, and so on. In 0.3.1 they were `chunk_1.csv`, `chunk_2.csv`, and so on.
>
> - Update any script, glob or import job that looks for `chunk_*.csv`.
> - splitlane doesn't delete old files. If you reuse an output directory from a 0.3.1 run, the old `chunk_*.csv` files stay next to the new `part-*.csv` files. A pipeline that still matches `chunk_*.csv` will then quietly read stale data. Start with an empty `--out` directory, or clear out the old files.
> - The new names are zero-padded, so they sort correctly as text (`part-0002` sorts before `part-0010`).

**B**

> **The output files have new names.** 0.3.1 wrote `chunk_1.csv`, `chunk_2.csv`, and so on. 0.4.0 writes `part-0001.csv`, `part-0002.csv`, and so on. Update any script, glob, or pipeline step that looks for `chunk_*.csv`.
>
> The zero padding makes the files sort in order by name, up to `part-9999.csv`. A run that writes more than 9,999 chunks produces five-digit names, and those don't sort correctly by name next to the four-digit ones.
>
> **Clear out old output directories.** 0.4.0 doesn't delete or overwrite `chunk_*.csv` files. If you write into a directory that 0.3.1 used, the old chunks stay next to the new ones. Empty the directory first, or pass a new `--out`.

<details>
<summary>Reveal A and B</summary>

- **A:** Without the skill, sample 2
- **B:** With the skill, sample 1

</details>

## 08 README edit

An update to the README, so users learn how long rows are handled before they run into it. Passage: the first two paragraphs or list items the edit adds about long rows.

**A**

> splitlane cuts a row that is longer than `--max-row-bytes` and still writes it.
> It does not skip the row. The chunk gets the first `--max-row-bytes` bytes of
> the row, and splitlane drops the rest of the row up to the next line break. The
> cut usually falls in the middle of a field. The row that gets written can then
> have too few columns or an unclosed quote. An importer may reject it, or accept
> the shortened row without noticing.
>
> splitlane measures a row's length as the bytes of the row encoded as UTF-8,
> without its final line break. A quoted field can contain line breaks. Those
> line breaks belong to the row and count toward its length.

**B**

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

<details>
<summary>Reveal A and B</summary>

- **A:** With the skill, sample 1
- **B:** Without the skill, sample 2

</details>

## 09 Catch-up

The message that catches Sam up on tomasz's open follow-up to issue #42. Passage: the passage that describes the follow-up Sam takes over.

**A**

> **Your follow-up.** After a truncation, the reader skips ahead to the next newline (`src/splitlane/split.py:24-29`), and it doesn't check whether that newline is inside quotes. If the newline sits inside a real multi-line field, the reader starts the next row in the middle of that field. tomasz called this probably rare and not blocking for 0.4.0, but nobody has measured how rare. The thread doesn't set a deadline or a scope either, so it's up to you whether to fix it before 0.4.0 or after.

**B**

> **Your follow-up.** After a row is truncated, the skip in `src/splitlane/split.py:24-29` goes to the next `\n` without tracking quotes. If that newline is inside a real multi-line field, the reader picks up again in the middle of that field. From there its quote state is flipped, so following rows can be split wrong or run into the byte limit again. Each failure is still capped at `--max-row-bytes`, so the file never gets swallowed. But one stray quote can damage more than the one row we promised. tomasz thinks it's rare and said it's not blocking. Nobody has measured how often it happens or prototyped a fix, so the approach is up to you. A good first step is a test case that triggers it: a stray quote, followed within the byte limit by a real multi-line quoted field.

<details>
<summary>Reveal A and B</summary>

- **A:** With the skill, sample 1
- **B:** Without the skill, sample 2

</details>

## 10 Agent rules

The `AGENTS.md` that coding agents load in every session. Passage: the rule about output file names, without its heading, for the same reason as 07.

**A**

> splitlane writes chunks as `part-0001.csv`, `part-0002.csv`, and so on, inside
> the `--out` directory (`src/splitlane/split.py`). Users' scripts depend on
> these names, so don't change them, including the padding width.
>
> A maintainer may ask for a rename, as one did for the zero-padded names in
> 0.4.0. When a maintainer asks, update the Usage section of `README.md` and add
> a line to `CHANGELOG.md` in the same change.

**B**

> Chunks are written as `<out>/part-0001.csv`, `part-0002.csv`, and so on (`split_file()` in `src/splitlane/split.py`). Users' pipelines depend on these names.
>
> - Don't change output file names unless a maintainer explicitly asks you to.
> - If a maintainer asks for a rename, also update `README.md` and `CHANGELOG.md` in the same change.

<details>
<summary>Reveal A and B</summary>

- **A:** With the skill, sample 1
- **B:** Without the skill, sample 3

</details>

## Key

<details>
<summary>Which side is A and which is B, per task</summary>

The order comes from `random.Random("runs/2026-11-01-claude-opus-5-5-2/base vs runs/2026-11-01-claude-opus-5-5-2/skill")`,
drawn once per task, with "first" meaning the side without the skill.

| Task | A | B |
|---|---|---|
| 01 README | With the skill, sample 1 | Without the skill, sample 3 |
| 02 Docstring | With the skill, sample 1 | Without the skill, sample 1 |
| 03 Email | With the skill, sample 1 | Without the skill, sample 1 |
| 04 Pitch | Without the skill, sample 3 | With the skill, sample 1 |
| 05 Failure reply | Without the skill, sample 3 | With the skill, sample 1 |
| 06 Decision record | With the skill, sample 1 | Without the skill, sample 1 |
| 07 Release notes | Without the skill, sample 2 | With the skill, sample 1 |
| 08 README edit | With the skill, sample 1 | Without the skill, sample 2 |
| 09 Catch-up | With the skill, sample 1 | Without the skill, sample 2 |
| 10 Agent rules | With the skill, sample 1 | Without the skill, sample 3 |

</details>

## Scores

### The Maintainer's Picks

Made blind, from the excerpts alone. The reasons are the maintainer's own,
lightly edited for spelling.

| Task | Pick | Side | Reason |
|---|---|---|---|
| 01 README | A | with the skill | It keeps a fixed number of rows per file, which matters more to me than the header. |
| 02 Docstring | B | without the skill | B has a good opening, and its first lines catch attention better. A's note is better to my taste. |
| 03 Email | A | with the skill | A hard pick, because it describes a complex problem. A is marginally better to my taste, and easier to get the idea from on the first pass. |
| 04 Pitch | B | with the skill | Marginally better. A had some sentences that were just redundant. Both read fine. |
| 05 Failure reply | B | with the skill | Shorter, with the same clarity. I didn't check whether B invented facts about the encoding. |
| 06 Decision record | B | without the skill | Better structure, and surprisingly simpler words that are easier to understand, even if it's longer. |
| 07 Release notes | B | with the skill | A almost won because of its bullets, but overall B is better writing and presents the facts better. |
| 08 README edit | A | with the skill | B lost my attention after mentioning RFC 4180, even though it was legitimately brought in. |
| 09 Catch-up | A | with the skill | Shorter. It has fewer facts, but it's good enough for a catch-up. |
| 10 Agent rules | A | with the skill | More accurate to my taste, or at least easier to parse the details from. |

Tally: with the skill 8, without it 2.

### The Writer's Picks

Made by the report's writer, after the key was known, so they aren't blind.

| Task | Pick | Reason |
|---|---|---|
| 01 README | With the skill | Says each file holds a fixed number of rows and that it works as a library. The other side's memory claim is useful too |
| 02 Docstring | Without it | Both name the resync risk. The side without the skill also tells callers what to do about it |
| 03 Email | With the skill | States the decision in one sentence and the problem in plain steps. The other side's "suppose someone runs…" takes longer to land |
| 04 Pitch | With the skill | Shorter at the same content, and says the change is all in the branch's CLI code |
| 05 Failure reply | With the skill | Same facts in fewer words. Its encoding claims match the log: `ISO-8859 text`, byte `0xe9`, exit status 3 |
| 06 Decision record | Without it | Numbered steps make the three parts of the decision easy to find |
| 07 Release notes | Without it | Only this side says a pipeline that still matches `chunk_*.csv` will quietly read stale data |
| 08 README edit | With the skill | Opens with what happens to the row, the thing the reader came for |
| 09 Catch-up | Even | The side with the skill is shorter. The other adds the flipped quote state and that each failure stays capped |
| 10 Agent rules | With the skill | Adds that the padding width is part of the contract, and names the README section to update |

Tally: with the skill 6, without it 3, even 1.

### Cost

Mean output tokens per session, thinking included, from `lib/stats.sh` and the
session JSON. "Main" is the session itself, and "subagent" is the cold-read
reader it started. Cold reads counts the skill sessions out of 3 that started
one. The side without the skill started no subagents.

| Task | Without: tokens | With: main | With: subagent | Without: s | With: s | Cold reads |
|---|---|---|---|---|---|---|
| 01 README | 3769 | 6643 | 1483 | 36 | 77 | 2 of 3 |
| 02 Docstring | 1413 | 1542 | 0 | 17 | 18 | 0 of 3 |
| 03 Email | 2313 | 4416 | 795 | 27 | 58 | 2 of 3 |
| 04 Pitch | 1150 | 1782 | 324 | 15 | 25 | 1 of 3 |
| 05 Failure reply | 2086 | 3642 | 889 | 24 | 49 | 2 of 3 |
| 06 Decision record | 2485 | 3384 | 0 | 27 | 36 | 0 of 3 |
| 07 Release notes | 3379 | 5031 | 755 | 35 | 56 | 1 of 3 |
| 08 README edit | 1811 | 3302 | 432 | 23 | 43 | 1 of 3 |
| 09 Catch-up | 1680 | 4099 | 704 | 23 | 56 | 2 of 3 |
| 10 Agent rules | 1937 | 3176 | 767 | 23 | 46 | 1 of 3 |

The whole run cost $10.65 at list price: $3.84 for the 30
sessions without the skill and $6.81 for the 30 with it, about
1.8 times as much. The skill loaded in 29 of its 30 sessions.
**Conclusion.** Judged blind, the maintainer preferred the side with the skill
in 8 of 10 tasks, although the sample rule tilts every pair against it. The
two tasks the other side won, the docstring and the decision record, are also
the only two where no skill session ran a cold read. With one sample shown per
side, that may be chance. The skill costs about 1.8 times as much per session
and takes about twice as long. Most of the extra is in the main session, not
the cold reader: a skill session wrote about 1,500 more output tokens than a
session without it, and its subagent about 600. One reader and one sample per
side make this a first signal, not a measurement.
