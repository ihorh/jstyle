# Sonnet 5.5 vs Opus 5.5, Both Without the Skill

| | |
|---|---|
| Runs | `runs/2026-11-01-claude-opus-5-5`, `runs/2026-11-01-claude-sonnet-5-5` |
| Models | `claude-opus-5-5`, `claude-sonnet-5-5`, default effort |
| Claude Code | 2.1.309, `claude -p` with no user or project settings |
| Inputs | `bench/world` and `bench/tasks` at `516400c` |
| Skill | none on either side |
| Samples | 3 per task on each side |
| Sample shown | Opus, the privileged side: sample 1. Sonnet: the best of its 3, picked by the report's writer |

Each task shows the same passage from both sides, labeled A and B in a seeded
random order. Each task ends with a collapsed reveal, so you can judge the
pair first and check right after. The Key section at the end collects all ten.
The recipe is in
[README.md](README.md).

**What to look for:**

- **Correct.** Does every claim come from the project's files, or does some
  fact appear from nowhere?
- **Understood.** Could the task's reader act on this without opening another
  file or asking?
- **Parsed in one pass.** Did any sentence send you back to reread it?

## 01 README

The public README, for someone deciding whether to use the tool. Passage: from
the title through the first two items of the first list.

**A**

> # splitlane
>
> Split a large CSV file into smaller CSV files. Every chunk starts with the input's header row.
>
> ```bash
> splitlane data/export.csv --rows 50000 --out chunks
> ```
>
> This writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on.
>
> ## Why use it
>
> - **Quoted newlines stay in one row.** A field like `"called twice⏎asked for refund"` is not split across two rows, as RFC 4180 specifies. (Fixed in 0.4.0, which is not released yet. See [Status](#status).)
> - **A malformed quote can't swallow the file.** A stray `"` damages at most one row. The reader stops at `--max-row-bytes`, truncates that row, and carries on.

**B**

> # splitlane
>
> splitlane splits a large CSV file into smaller files. Each output file starts with the input's header row.
>
> ```bash
> splitlane data/export.csv --rows 50000 --out chunks
> ```
>
> This writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on. Each chunk holds up to 50,000 data rows plus the header.
>
> ## What it does and doesn't do
>
> - **Every chunk gets the header.** The first row of the input is the header, and it is copied to the top of every chunk.
> - **Quoted newlines stay in their row.** A field in double quotes can contain line breaks, as RFC 4180 allows. That whole field stays in one row and is never split across two rows or two chunks. For example, this input has two data rows, not three:
>
>   ```
>   id,name,notes
>   7,Ana,"called twice
>   asked for refund"
>   8,Bo,ok
>   ```

<details>
<summary>Reveal A and B</summary>

A is Sonnet, sample 2. B is Opus, sample 1.

</details>

## 02 Docstring

The docstring of `read_row()`, for a caller who won't read its body. Passage:
every sentence about what happens when a row is truncated.

**A**

```text
- `(text, True)`: the row exceeded `max_row_bytes`. `text` holds only the
  content read before the limit was passed. The rest of the row is discarded
  up to the next newline, whether or not that newline is inside quotes.
  Because of this, the next call may start mid-record if the discarded part
  contained a quoted newline. `text` may end inside an open quote.
[…]
Note:
    An unterminated quote makes the row run to the end of input, or until
    `max_row_bytes` is exceeded.
```

**B**

```text
* ``(row, True)`` when the record is longer than ``max_row_bytes``.
  ``row`` holds the first ``max_row_bytes`` bytes of the record or
  fewer, so it may stop partway through a field or leave a quote
  unclosed. The rest of the line is read and thrown away.
[…]
* When a record is truncated, the rest is discarded up to the next
  ``"\\n"`` even if that newline is inside a quoted field. If an
  oversized record has a quoted multi-line field, the part after that
  newline is returned by the next call as if it were a separate
  record, and the records that follow it may be split in the wrong
  places.
```

<details>
<summary>Reveal A and B</summary>

A is Sonnet, sample 1. B is Opus, sample 1.

</details>

## 03 Email

devi's email to Priya, who owns the release decision and isn't technical.
Passage: the sentences that state the decision, and the paragraph that
describes the problem.

**A**

> The 0.4.0 release is ready except for one known problem. I need you to decide whether we ship it now or hold it until that problem is fixed.
>
> […]
>
> **The known problem**
>
> splitlane cuts one big file into many smaller ones. If a run fails partway through, it leaves a half-finished set of files behind, mixed in with files from the previous run, and it doesn't say which files are new and which are old. Someone who misses the failure could load a mix of old and new data.
>
> I first raised this as a Windows-only issue. It happens there when one of the output files is open in Excel. Since then I've found it's wider than that. Any run that stops partway leaves the same mix of files, on any computer, including the Linux machines billing and support analytics use. One example is an input file saved in an unexpected format. What limits the damage is that the run always ends with a clear error, so a person or script that checks for errors will see it.

**B**

> I need a decision from you on splitlane 0.4.0. The release is ready, with one known problem on Windows. Do we ship now and warn Windows users, or hold the release until I fix it?
>
> […]
>
> **The problem (#57, Windows only)**
> If a file from an earlier run is still open in Excel, splitlane crashes when it tries to replace that file. The files it wrote before the crash stay on disk, and the error doesn't say which ones. The user is left with a mix of new and old files and no clear way to tell which is which.

<details>
<summary>Reveal A and B</summary>

A is Opus, sample 1. B is Sonnet, sample 3.

</details>

## 04 Pitch

tomasz's comment on devi's merge request, pitching a change to her own branch.
Passage: from the opening through the paragraph that states the proposal.

**A**

> Hi devi, a suggestion before this merges. I'm not blocking it.
>
> As I read the branch, it counts every row first so it can show a percentage, then reads the file again to split it. That means two full passes over the input. On our biggest exports the counting pass alone takes a noticeable amount of time. I haven't timed it, so I can't say how much yet. I can get numbers if that would help.
>
> **My idea: skip the pre-count and stream.** Instead of a percentage, show rows processed and chunks written as they happen, e.g. `1,240,000 rows · 13 chunks written`. Then we only read the input once. `split_file()` already reads row by row, so I think the change stays in the CLI code on this branch and `split.py` doesn't need restructuring.

**B**

> Hi devi, thanks for the progress bar work. I have one suggestion to raise before this merges.
>
> **The concern:** the branch counts every row before splitting so it can show a percentage. That means reading the whole input twice. On our biggest exports I expect the first pass alone to take a noticeable while. I haven't timed it, so that's a guess, and I'll measure it if you'd like numbers.
>
> **Proposal:** drop the pre-count and report "rows processed" and chunks written instead of a percentage. That gives one pass over the input. `split_file()` already reads row by row, so the change should be confined to the CLI code in this branch. I'm happy to do that part.

<details>
<summary>Reveal A and B</summary>

A is Opus, sample 1. B is Sonnet, sample 2.

</details>

## 05 Failure Reply

The maintainer's reply to a user who pasted a failed run. Passage: what went
wrong, and what the reply says about the partial chunk.

**A**

> **What went wrong**
>
> Your export isn't UTF-8. `file` reports it as `ISO-8859 text`, which means a Latin-1 or Windows-1252 encoding. Byte `0xe9` is `é` in those encodings, but it isn't valid UTF-8 on its own. splitlane reads input as UTF-8 unless you tell it otherwise, so it stopped at the first accented character (byte 4183) and exited with status 3, which means it couldn't decode the input.
>
> **About `chunks/part-0001.csv`: don't use it.** splitlane writes chunks while it reads the input, and it doesn't clean up when it fails. That file is left over from the failed run. It has the header plus the 182 rows read before the error, out of the 20,000 you asked for. The rest of the file was never processed.

**B**

> **What went wrong**
>
> `splitlane` reads input as UTF-8 unless you tell it otherwise. Your export is not UTF-8. `file` reports it as ISO-8859 (Latin-1 style). Byte `0xe9` is `é` in that encoding, and it isn't valid UTF-8. The decode failed at byte 4183, so `splitlane` stopped and exited with status 3. That is the exit code for "input cannot be decoded".
>
> The run did not fail cleanly. It wrote `chunks/part-0001.csv` before it hit the bad byte, and that file holds only 183 lines. You asked for 20000 rows per chunk, so it is incomplete.

<details>
<summary>Reveal A and B</summary>

A is Opus, sample 1. B is Sonnet, sample 2.

</details>

## 06 Decision Record

The decision record for issue #42, for contributors who won't read the thread.
Passage: the section that states the decision.

**A**

> ## Decision
>
> `read_row()` tracks quotes, so a newline inside quotes stays in the row. The tracking is bounded:
>
> - If a row grows past `--max-row-bytes` (default 65536), the reader stops and returns what it has, flagged as truncated.
> - It then skips ahead to the next newline and resumes reading rows from there.
> - The limit is in bytes, not lines. A legitimate note can have many lines, so counting lines would reject valid data.
>
> Truncation is reported, not silent:
>
> - `read_row()` returns `(row, was_truncated)`. Library callers get the flag.
> - `split_file()` returns the count of truncated rows.
> - The CLI prints `warning: N row(s) longer than <limit> bytes were truncated` to stderr at the end of a run. Callers who script around splitlane (the billing and support teams do) should check for this message.

**B**

> ## Decision
>
> 1. `read_row()` tracks quotes. A `\n` inside a quoted field stays part of the row. This matches RFC 4180 and spreadsheet behavior.
> 2. The `--max-row-bytes` limit (default 65536) bounds quote tracking. If a row grows past the limit, the reader stops, keeps what it has, marks the row as truncated, and skips ahead to the next `\n`. From there it continues normally.
> 3. Truncation is never silent:
>    - `read_row()` returns `(row, truncated)`.
>    - `split_file()` returns `(written_files, truncated_count)`.
>    - The CLI prints `splitlane: warning: N row(s) longer than M bytes were truncated` to stderr at the end of a run.
>
> A legitimate multi-line field stays far below the limit. A stray quote hits the limit, so it damages one row and doesn't swallow the rest of the file.

<details>
<summary>Reveal A and B</summary>

A is Sonnet, sample 3. B is Opus, sample 1.

</details>

## 07 Release Notes

The 0.4.0 release notes, for users upgrading from 0.3.1. Passage: the entry
about the renamed output files.

**A**

> **Output files are renamed.** Chunks are now named `part-0001.csv`, `part-0002.csv` and so on. In 0.3.1 they were `chunk_1.csv`, `chunk_2.csv`. The numbers are zero-padded to four digits, so the files sort correctly. If a script or glob expects `chunk_*.csv`, update it to `part-*.csv`.

**B**

> ### Output files have new names
>
> Chunks used to be named `chunk_1.csv`, `chunk_2.csv`, … and are now named `part-0001.csv`, `part-0002.csv`, …
>
> - Update any script, glob, or downstream job that looks for `chunk_*.csv`.
> - splitlane does not delete old files. If you reuse an output directory from 0.3.1, the old `chunk_*.csv` files will still be there next to the new `part-*.csv` files. Clear the directory first, or use a new one.
> - The number has four digits. A run with more than 9,999 chunks continues with `part-10000.csv`, which sorts out of order in a plain text sort.

<details>
<summary>Reveal A and B</summary>

A is Sonnet, sample 1. B is Opus, sample 1.

</details>

## 08 README Edit

An edit to the existing README, so users learn how long rows are handled.
Passage: the first two paragraphs or list items the edit adds about long rows.

**A**

> ## Long rows
>
> A row can span several lines when a quoted field contains a newline, and it stays one row. Row length is measured in UTF-8 bytes, not counting the line ending that ends the row.
>
> A row longer than `--max-row-bytes` is truncated, not skipped:
>
> - The first `--max-row-bytes` bytes of the row are written to the chunk, and the rest is dropped. A truncated row may have fewer columns than the header, or an unclosed quote.
> - splitlane drops input up to the next newline, even a newline inside quotes, and starts the next row there. If the cut happens inside a multi-line quoted field, the remaining lines of that field can show up as extra, broken rows.

**B**

> ## Long rows
>
> A quoted field can contain line breaks, and splitlane keeps those inside one row. A row ends at the first line break that is not inside quotes.
>
> To keep one stray `"` from turning the rest of the file into a single field, splitlane limits how long a row can get. A row that grows past `--max-row-bytes` (counted in UTF-8 bytes) is cut at that limit. The rest of it is skipped up to the next line break, and reading continues from there. The shortened row is still written to the output, so the chunk keeps its row count, but its data is incomplete.

<details>
<summary>Reveal A and B</summary>

A is Opus, sample 1. B is Sonnet, sample 3.

</details>

## 09 Catch-Up

A message to Sam, who joins the project and takes over tomasz's follow-up.
Passage: the description of that follow-up.

**A**

> **Your follow-up.** tomasz noticed that the skip after a truncation stops at the next `\n` even when that newline is inside quotes, so the reader can pick up again in the middle of a real multi-line field. They called it "probably rare, not blocking."
>
> From reading the code, I think a bad case could be worse than one bad row. I haven't tested this. The next `read_row()` call starts with `in_quotes = False`. If it starts partway through a quoted field, it will read that field's closing `"` as an opening quote. It could then run to the byte limit and truncate again, possibly more than once before it gets back in step. Each step is still bounded, so it can't swallow the file, but it may damage more rows than the one warning suggests. A good first step would be a test that reproduces this: a stray quote followed soon after by a real multi-line notes field.

**B**

> **The open follow-up (tomasz, 2026-10-03)**
> After truncation, the skip goes to the next `\n` even if that newline is inside quotes. It's at `src/splitlane/split.py:24-28`, and the comment there says "quoted or not". If a stray quote forces a truncation, the reader may resume in the middle of a real multi-line field.
>
> My reading of the code, which I haven't run: the next `read_row()` call starts with `in_quotes = False`. The closing quote of that half-read field would then flip it to "inside quotes". The next row's newline could then be swallowed until another quote shows up, or until the limit is hit again. So one bad quote could damage more than one row. It would still be bounded, not a swallowed file.
>
> tomasz called it probably rare and not blocking. Nobody has measured how often it happens, and nobody has reproduced it or written a test for it. No fix has been proposed or agreed.

<details>
<summary>Reveal A and B</summary>

A is Opus, sample 1. B is Sonnet, sample 3.

</details>

## 10 Agent Rules

The `AGENTS.md` built from devi's draft rules, for coding agents. Passage: the
rule about output file names.

**A**

> ## 1. Don't change output file names
>
> Chunks are written as `<out>/part-0001.csv`, `<out>/part-0002.csv` and so on, numbered from 1 and zero-padded to 4 digits. Users' scripts depend on these names.
>
> - Change the names only when a maintainer explicitly asks for it. Cleanup, consistency and refactoring are not reasons.
> - If a maintainer does ask, update `README.md` and add a line to `CHANGELOG.md` in the same change.

**B**

> ## Output file names
>
> - Never change output file names.
> - Exception: a maintainer explicitly asks for it, as with the 0.4.0 rename. In that case, also update the README and the changelog.

<details>
<summary>Reveal A and B</summary>

A is Opus, sample 1. B is Sonnet, sample 1.

</details>

## Key

<details>
<summary>Which side is A and which is B, per task</summary>

The order comes from `random.Random("2026-11-01-claude-opus-5-5 vs 2026-11-01-claude-sonnet-5-5")`,
drawn once per task. Opus always shows sample 1. Sonnet shows the sample named.

| Task | A | B |
|---|---|---|
| 01 README | Sonnet, sample 2 | Opus |
| 02 Docstring | Sonnet, sample 1 | Opus |
| 03 Email | Opus | Sonnet, sample 3 |
| 04 Pitch | Opus | Sonnet, sample 2 |
| 05 Failure reply | Opus | Sonnet, sample 2 |
| 06 Decision record | Sonnet, sample 3 | Opus |
| 07 Release notes | Sonnet, sample 1 | Opus |
| 08 README edit | Opus | Sonnet, sample 3 |
| 09 Catch-up | Opus | Sonnet, sample 3 |
| 10 Agent rules | Opus | Sonnet, sample 1 |

</details>

## Scores

*Withheld until the first reader has made their guesses. This section will
then give the writer's pick per task with a one-line reason, the stats, and a
short conclusion.*
