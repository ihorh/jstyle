# 0001: Keep quoted newlines in the row, bounded by `--max-row-bytes`

- **Status:** Accepted. Merged 2026-10-02, targeted for 0.4.0.
- **Issue:** #42
- **Code:** `read_row()` in `src/splitlane/split.py`

## Context

splitlane splits a CSV into chunks by reading one row at a time with `read_row()`.

Up to 0.3.x, `read_row()` ended a row at the first `\n` and ignored quotes. This was a deliberate choice in 0.1. If the reader tracks quotes, one malformed quote can make it treat the rest of the file as a single field. "Never swallow the file" was ranked above "handle quoted newlines".

That choice broke valid input. RFC 4180 allows a newline inside a quoted field, and real exports use this. A CRM export with a multi-line `notes` column is one example:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

This file has two data rows, but splitlane wrote three. The second of those had the wrong number of columns, so downstream importers rejected the whole chunk. Two internal teams, billing and support analytics, were blocked by this. Neither team had seen a malformed quote in their exports.

## Decision

1. `read_row()` tracks quotes. A `\n` inside a quoted field stays part of the row. This matches RFC 4180 and spreadsheet behavior.
2. The `--max-row-bytes` limit (default 65536) bounds quote tracking. If a row grows past the limit, the reader stops, keeps what it has, marks the row as truncated, and skips ahead to the next `\n`. From there it continues normally.
3. Truncation is never silent:
   - `read_row()` returns `(row, truncated)`.
   - `split_file()` returns `(written_files, truncated_count)`.
   - The CLI prints `splitlane: warning: N row(s) longer than M bytes were truncated` to stderr at the end of a run.

A legitimate multi-line field stays far below the limit. A stray quote hits the limit, so it damages one row and doesn't swallow the rest of the file.

## Alternatives considered

- **Keep the 0.1 behavior (no quote tracking).** Rejected. It mangles valid, common input to protect against a malformed case that nobody affected had seen.
- **Plain quote tracking with no bound.** Rejected after testing. One stray `"` in row 12 of a 400k-row file made the reader treat everything after row 12 as one field. The output was a chunk with a header and one huge row, which is the exact failure the 0.1 design was meant to prevent.
- **Treat a quoted field as broken after N lines.** Rejected. A notes field can legitimately span many lines, so no line count works as a threshold. A byte limit fits better, and `--max-row-bytes` already existed.

## Consequences

- Valid multi-line quoted fields are preserved.
- A malformed quote costs one truncated row, not the rest of the file.
- Any row longer than `--max-row-bytes` is cut, including a legitimate one. Users with very large fields have to raise the limit.
- A truncated row is still written to the chunk. Callers who need complete data must check the warning (CLI) or the `truncated` flag (library). Billing and support analytics plan to check for the CLI warning in their scripts.
- A row truncated by a stray quote is written with that quote still unclosed. A strict CSV parser reading the chunk later may misread the rows after it.
- **Known gap:** after truncation, the reader skips to the next raw `\n`, even if that newline is inside quotes. In a bad case, the reader can resync in the middle of a real multi-line field and misread the rows that follow. This was judged rare and doesn't block the change. It is still an open follow-up.
- The limit counts UTF-8 bytes of the row and excludes the row's terminating newline.
