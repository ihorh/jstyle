# 0001: Keep quoted newlines in the row, and bound the damage from a stray quote

Status: accepted. Merged 2026-10-02 (issue #42), shipping in 0.4.0.

## Context

splitlane cuts a CSV into chunks of N rows. Up to 0.3, `read_row()` in `src/splitlane/split.py` ended a row at the first `\n` and ignored quotes. That was deliberate. If the reader tracks quotes, one malformed quote (a stray `"`) makes it treat everything after it as a single field, and the rest of the file is swallowed.

The trade-off was wrong for real data. RFC 4180 allows a quoted field to contain line breaks, and CRM exports with a free-text `notes` column do this. The old reader split one record into two, and the second had the wrong column count. The downstream importer then rejected the whole chunk. Two teams (billing and support analytics) were blocked on it. Neither had seen a malformed quote in their exports.

## Decision

1. `read_row()` tracks quotes, so a newline inside quotes stays in the row.
2. `--max-row-bytes` (default 65536) caps the row length. When a row passes the cap, the reader stops there and returns what it has with a truncated flag. It then skips ahead to the next newline.
3. Truncation is never silent. `read_row()` returns `(row, was_truncated)`, and the CLI prints the number of truncated rows to stderr at the end of a run.

We rejected two alternatives:

- **Keep ignoring quotes.** This is safe against a stray quote, but it keeps breaking valid files, which are the common case.
- **Treat a quoted field that spans N lines as broken.** A legitimate note can have many lines, so a line count gives false positives. A byte cap does not, because real notes stay far below it.

## Consequences

- Valid multi-line fields round-trip intact.
- A stray quote no longer swallows the file. It costs at least one row, which is cut at `--max-row-bytes`.
- Callers who need to know about damaged rows must check the flag or the CLI message. The importer scripts that motivated this change check for the message.
- **The cap is part of the correctness story, not only a memory limit.** Raising the default, or making it unlimited, brings back the swallowed file in the stray-quote case. Change it only deliberately.

## Known limits

- After a truncation, the skip to the next newline ignores quotes. If that newline sits inside a real multi-line field, the reader resyncs in the middle of that record. This was raised in #42 and judged rare. It is not fixed.
- This is our reading of the code, and we have not tested it. A stray quote loses every row that falls within the next `--max-row-bytes` bytes, because they all merge into the one truncated row. Issue #42 describes this as "one damaged row", which holds only when rows are long. The count reported at the end tallies one truncated row, not the rows lost.
