# 0001: Keep quoted newlines inside the row, bounded by `--max-row-bytes`

- **Status:** Accepted. Merged 2026-10-02, ships in 0.4.0.
- **Issue:** #42

## Context

Up to 0.3.x, `read_row()` ended a row at the first `\n` and ignored quotes completely. This was deliberate. If the reader tracks quotes, one malformed quote can make it treat the rest of the file as a single field. The original choice put "never swallow the file" ahead of "handle quoted newlines".

That choice broke real input. RFC 4180 lets a quoted field contain line breaks, and spreadsheets handle them. CRM exports with a free-text `notes` column often have them. For example:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

This file has two data rows, but splitlane wrote three. The second piece of row 7 had the wrong number of columns, so downstream importers rejected the whole chunk. Two teams, billing and support analytics, were blocked on this. Neither had ever seen a malformed quote in their exports.

The first fix was plain quote tracking. In testing it failed exactly as feared: one stray `"` in row 12 of a 400k-row file made everything after it one field. The output was a single chunk holding a header and one enormous row. So plain quote tracking was not enough.

## Decision

1. **Track quotes in `read_row()`.** A `\n` inside double quotes stays in the field. Only a `\n` outside quotes ends the row.
2. **Limit row size with the existing `--max-row-bytes` (default 65536).** If a row grows past the limit, the reader stops, returns what it has read so far, marks the row as truncated, and skips ahead to the next `\n`. Real multi-line notes stay far below the limit. A stray quote hits it, damages one row, and the reader recovers.
3. **Never truncate silently.**
   - `read_row()` returns `(row, truncated)`, so library callers can check each row.
   - `split_file()` returns the number of truncated rows.
   - The CLI prints a warning to stderr at the end of a run, e.g. `splitlane: warning: 3 row(s) longer than 65536 bytes were truncated`. Users who need to catch damaged rows can check for this line in their scripts.

## Alternatives considered

- **Keep ignoring quotes (the 0.1 behavior).** Rejected. It breaks valid RFC 4180 input, and that is far more common in practice than malformed quotes.
- **Plain quote tracking with no limit.** Rejected. One stray quote can swallow the rest of the file (see Context).
- **Treat a quoted field as broken once it spans more than N lines.** Rejected. Real notes fields can span many lines, so no fixed N works. A byte limit fits better and reuses an option that already exists.

## Consequences

- Valid multi-line quoted fields now split correctly.
- A malformed quote costs about one row instead of the rest of the file. The damaged row is written cut short and may have the wrong column count. The run still exits with status 0, so the stderr warning is the only signal.
- A legitimate row longer than `--max-row-bytes` is now truncated too. Users with very long fields have to raise the limit.
- `--max-row-bytes` now does two jobs: it limits row length, and it is the recovery mechanism for malformed quotes. Think about both before changing its default or removing it.
- Quote tracking adds a little work per character in `read_row()`, which still reads one character at a time.

## Known limitation (open follow-up)

After truncation, the reader skips to the next `\n` *whether or not that newline is inside quotes*. In the worst case it can resync in the middle of a real multi-line field, and later rows come out misaligned. This is probably rare, and it did not block the 0.4.0 fix. It is still not fixed. If you work on it, start with the skip loop that runs after the size check in `read_row()` (`src/splitlane/split.py`).
