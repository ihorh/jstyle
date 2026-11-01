# 0001: Quoted newlines stay in the row, bounded by `--max-row-bytes`

- Status: Accepted (shipping in 0.4.0)
- Date: 2026-10-02
- Issue: #42

## Context

splitlane splits a CSV into chunks of N rows, repeating the header in each chunk. Before 0.4.0, `read_row()` in `src/splitlane/split.py` ended a row at the first `\n` and ignored quotes. This was deliberate in 0.1. Tracking quotes means one malformed quote can make the reader treat the rest of the file as a single field, and we preferred never swallowing a file to handling quoted newlines.

That choice broke valid input. RFC 4180 allows line breaks inside quoted fields, and real exports have them. A CRM export with a multi-line `notes` column was split into rows with the wrong column count, and the downstream importer rejected the whole chunk. Two teams (billing and support analytics) were blocked.

Naive quote tracking fixes that case but brings back the old failure. With a single stray `"` in row 12 of a 400k-row file, everything after row 12 was read as one field. The output chunk had a header and one enormous row.

## Decision

`read_row()` tracks quote state, so a newline inside quotes stays in the row. The tracking is bounded by the existing `--max-row-bytes` limit (default 65536):

- If a row grows past the limit, the reader stops, returns what it has, and flags the row as truncated.
- It then skips ahead to the next `\n` and resumes reading from there.
- A stray quote therefore damages one row instead of the rest of the file.
- The truncation is reported, not silent. `read_row()` returns `(row, was_truncated)`, `split_file()` returns a truncated-row count, and the CLI prints a warning with that count to stderr at the end of the run.

## Alternatives considered

- **Keep splitting at every newline.** This is the 0.1 behavior. It is safe, but it corrupts valid multi-line fields, which are far more common in real exports than malformed quotes. The affected users had never seen a malformed quote.
- **Unbounded quote tracking.** This is simple and RFC-correct, but one stray quote swallows the file.
- **Treat a quoted field as broken after N lines.** Rejected because a legitimate note can have many lines. Byte size is a better signal than line count.

## Consequences

- **Truncation is data loss.** A row that exceeds `--max-row-bytes` is cut, whether or not it was malformed. The row looks shortened to an importer, so the only signal is the stderr warning and the library flag. Callers that care must check the warning or the flag. The billing and support teams have said they will check for the CLI message in their scripts. Don't remove or reword that message without telling them.
- **Raising `--max-row-bytes` has a cost.** A higher limit lets legitimate large fields through, but a stray quote then damages more data before the reader stops.
- **Known gap: resync can land inside a quoted field.** After truncation the skip goes to the next `\n` without regard to quotes. If that newline is inside a real multi-line field, the reader resumes mid-field, and the following row or rows may be garbled. This is believed to be rare and was accepted as non-blocking, but it is not fixed. A fix would need to pick a resync point that is more likely to be a real row boundary. Any such change should be recorded in a new decision record.
- **Chunks are no longer line-aligned.** A row can span several physical lines, so line counts in the output don't match row counts.

## Where this lives

- `src/splitlane/split.py`: `read_row()`, `split_file()`
- `src/splitlane/cli.py`: truncation warning
- `CHANGELOG.md`: 0.4.0 entries referencing #42
