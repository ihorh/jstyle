# 0001: Keep quoted newlines inside the row, and cap each row at `--max-row-bytes`

- **Status:** Accepted. Merged 2026-10-02 and scheduled for 0.4.0.
- **Issue:** #42, "Rows with newlines inside quotes get split in two"
- **Participants:** devi, tomasz, maya

## Context

Before 0.4.0, `read_row()` in `src/splitlane/split.py` ended a row at the first `\n` and ignored quotes completely. RFC 4180 lets a quoted field contain line breaks, so a valid CSV like this one was split wrongly:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

This file has two data rows, but splitlane wrote three. The extra row had the wrong number of columns, and the importer downstream rejected the whole chunk. Two teams, billing and support analytics, were blocked. Both get CRM exports that have a free-text `notes` column.

The 0.1 behavior was intentional. Once a reader tracks quotes, one stray `"` makes it read everything after that quote as a single field. devi chose "never swallow the file" over "handle quoted newlines." No one in the thread had numbers on how often each case happens. The teams that were blocked had never seen a malformed quote, but they had real multi-line fields.

Quote tracking on its own was not enough. devi built it and tested it on a 400k-row file with one stray `"` in row 12. The output was a single chunk that held the header and one enormous row, which is the failure 0.1 was designed to prevent.

## Decision

`read_row()` tracks quotes, and a newline inside quotes stays in the field. Each row is also capped by the existing `--max-row-bytes` limit, which defaults to 65536 bytes:

1. When a row grows past the limit, the reader stops adding to it, marks it as truncated, and skips ahead to the next newline. It then starts the next row there.
2. The truncated row is still written to the output, cut off at the limit.
3. Truncation is never silent. `read_row()` returns a `(row, truncated)` pair, and `split_file()` returns the number of truncated rows. The CLI prints this warning to stderr at the end of a run:
   `splitlane: warning: N row(s) longer than M bytes were truncated`.
   The billing and support analytics teams said they will check for this warning in their scripts.

## Alternatives considered

- **Keep the 0.1 behavior.** This was rejected because it breaks valid RFC 4180 files, and those files are common in real exports.
- **Unbounded quote tracking.** This matches what spreadsheets do. It was rejected because one stray quote swallows the rest of the file, as the test in row 12 showed.
- **Treat a quoted field as broken once it spans more than N lines.** This was rejected because a legitimate notes field can have many lines, so no line count separates good input from bad. A byte limit works better because a real note stays far below 64 KiB, while a runaway quote reaches the limit quickly.

## Consequences

- Valid multi-line fields now survive splitting.
- In the worst case, a stray quote damages a bounded amount of data, where before it could swallow the rest of the file.
- A legitimate row longer than `--max-row-bytes` is now truncated, though it would have been split before. Users who have very long rows should raise the limit.
- The damage from a stray quote is larger than "one row." The thread described it as one damaged row, but my reading of `read_row()` is that every row after the stray quote, up to the byte limit, gets absorbed into the truncated row. Those rows are lost from the output, and the warning counts them all as one truncated row. With the default limit and rows of about 100 bytes, that is several hundred rows.
- `--max-row-bytes` now controls correctness as well as memory. Changing its default changes which rows get truncated.

## Open issues

- **The reader can resync inside a quoted field.** After truncation, the reader skips to the next newline, even when that newline is inside quotes. In a bad case it can restart in the middle of a real multi-line field, and the rows that follow are misread. tomasz raised this on 2026-10-03, and it was judged rare and not blocking.
- **Truncated rows can carry an open quote into the output.** This was not discussed in #42. A truncated row from a stray quote still contains that unclosed `"` when it is written to a chunk. A downstream parser that follows RFC 4180 may then read the rest of that chunk as one field.
