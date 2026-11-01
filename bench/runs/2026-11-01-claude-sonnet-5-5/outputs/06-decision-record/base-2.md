# 0001: Quoted newlines stay in the row, bounded by `--max-row-bytes`

- Status: Accepted and implemented (merged 2026-10-02, ships in 0.4.0)
- Issue: #42

## Context

RFC 4180 allows a quoted field to contain line breaks. Up to 0.3.x, `read_row()` in `src/splitlane/split.py` ended a row at the first `\n` and ignored quotes. A CRM export with a multi-line `notes` column was therefore split into extra, malformed rows. Downstream importers rejected the whole chunk.

The 0.1 behavior was deliberate. If the reader tracks quotes, one stray `"` can make it treat the rest of the file as a single field. The original author chose "never swallow the file" over "handle quoted newlines".

Two teams (billing and support analytics) were blocked by the old behavior. Neither had seen a malformed quote in their exports. Nobody had data on how common each case is, but legitimate multi-line fields were expected to be far more common.

## Decision

1. `read_row()` tracks quote state. A newline inside quotes stays in the row.
2. The `--max-row-bytes` limit bounds that tracking. When a row grows past the limit, the reader stops and returns the row cut at the limit. It flags the row as truncated, then skips input up to the next `\n` and resumes from there.
3. Truncation is never silent:
   - The library path: `read_row()` returns `(row, was_truncated)`, and `split_file()` returns the truncated count.
   - The CLI path: it prints a warning to stderr with the count of truncated rows at the end of a run.

## Why

- Handling quoted newlines is what RFC 4180 specifies and what spreadsheets do. It fixes the reported bug.
- Plain quote tracking was tried and rejected. A test file with one stray `"` in row 12 of 400k rows produced a chunk with a header and one enormous row. That is the failure the 0.1 design was avoiding.
- Counting lines in a quoted field doesn't work as a guard, because a legitimate notes field can span many lines.
- `--max-row-bytes` already existed (added in 0.3.0). A legitimate multi-line note stays far below the default of 65536 bytes. A stray quote hits the limit, damages one row, and the reader recovers at the next newline. The worst case is one damaged row, not a swallowed file.
- The truncation count is how consumers find out about lost data. A truncated row looks like a shortened row to an importer. The affected teams said they would check for the CLI warning in their scripts. Treat that message as a contract (see Consequences).

## Consequences

- A stray quote now costs one damaged row, plus any rows consumed before the limit is hit, up to roughly `--max-row-bytes` of input. It no longer costs the rest of the file.
- Raising `--max-row-bytes` makes that damage larger. Lowering it below the size of real multi-line fields truncates good data. Don't change the default to make a test pass.
- Truncated rows are written to the output as cut. Their quotes may be unbalanced, so they are not valid CSV rows. Consumers should treat a nonzero truncation count as a signal to inspect the output.
- Users script against the stderr warning (`N row(s) longer than ... bytes were truncated`). Changing its wording or dropping it is a breaking change for them.

## Known limitation

The skip after truncation goes to the next `\n` whether or not that newline is inside quotes. After a truncation, the reader can therefore resynchronize in the middle of a real multi-line field. The next row or two may then be split wrongly or have the wrong column count. This was judged rare and was not a blocker. Fixing it would need a smarter resync strategy, and none has been designed yet.

## Alternatives considered

- **Keep 0.1 behavior (newline always ends the row).** Rejected. It is the bug in #42, and it blocks real users.
- **Track quotes with no bound.** Rejected. One stray quote swallows the rest of the file.
- **Truncate a quoted field after N lines.** Rejected. Legitimate fields can have many lines, so a line count can't tell them from a stray quote. Byte size is a better proxy.
