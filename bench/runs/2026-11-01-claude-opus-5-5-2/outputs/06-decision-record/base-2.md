# 0001: Keep newlines inside quoted fields, with a size limit on each row

- Status: Accepted. Merged 2026-10-02. Ships in 0.4.0 (not yet released).
- Issue: #42
- Code: `read_row()` in `src/splitlane/split.py`, truncation warning in `src/splitlane/cli.py`

## Context

Up to 0.3.x, `read_row()` ended a row at the first `\n` and ignored quotes. This was a deliberate choice from 0.1. If the reader tracks quotes, one malformed `"` can make it treat the rest of the file as a single field. The original trade-off was to never swallow the file, even if that meant not handling quoted newlines.

This breaks valid RFC 4180 input. CRM exports often have a free-text `notes` column with line breaks, quoted correctly:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

splitlane wrote three data rows for this file instead of two. The extra row had the wrong number of columns, and downstream importers rejected the whole chunk. Two internal teams were blocked: billing and support analytics. Neither had ever seen a malformed quote in their exports. We have no data on how often malformed quotes occur compared with real multi-line fields.

The risk is real, though. An early version of quote tracking was tested on a 400k-row file with one stray `"` in row 12. It read everything after row 12 as one field and produced a chunk with a header and one huge row.

## Decision

1. **Track quotes in `read_row()`.** A `"` toggles the in-quotes state, and a `\n` inside quotes stays in the field. This matches RFC 4180 and how spreadsheets behave.
2. **Use `--max-row-bytes` as the limit on how far quote tracking can run.** The option already existed (added in 0.3.0, default 65536). If a row grows past the limit, the reader:
   - keeps the first `max_row_bytes` bytes as the row,
   - throws away input up to the next `\n`, whether or not that newline is quoted,
   - marks the row as truncated and continues from the next line.

   The truncated row is still written to the output in its shortened form.
3. **Report truncation, so data is never lost silently.**
   - Library: `read_row()` returns `(row, truncated)`, and `split_file()` returns `(written_files, truncated_count)`.
   - CLI: at the end of a run, splitlane prints `splitlane: warning: N row(s) longer than M bytes were truncated` to stderr. The exit status is still 0.

With this design, a stray quote damages one row instead of the rest of the file. Valid multi-line fields stay well under the limit and are not affected.

## Alternatives considered

- **Keep the 0.1 behavior (newline always ends a row).** Rejected. It breaks valid, common input to protect against a failure that nobody involved had seen.
- **Unbounded quote tracking.** Rejected. A single stray quote swallows the rest of the file, which was shown in testing.
- **Treat a quoted field as broken after N lines.** Rejected. Valid notes fields can have many lines, so no line count works. A byte limit does, and we already had one.

## Consequences

- Valid multi-line quoted fields stay in one row.
- A malformed quote causes one truncated row instead of a corrupted file. The truncated row is short, may have the wrong number of columns, and the discarded part cannot be recovered.
- Any row longer than `--max-row-bytes` is truncated, whether or not it contains a stray quote. Users with very large valid rows have to raise the limit.
- **Users rely on the warning.** Billing and support analytics check their scripts for the truncation message, because exit status 0 does not show that rows were truncated. Changing the wording, moving the message off stderr, or removing it will break them. Treat it as part of the interface.
- Do not change the default of `--max-row-bytes` to fix a failing test. The default determines how much damage a stray quote can do.

## Known limitation (open follow-up)

After a truncation, the reader skips to the next raw `\n`, even if that newline is inside quotes. If truncation happens inside a real multi-line field, the reader can resume in the middle of that field. Quote tracking then starts in the wrong state, and the following rows may be damaged too. This is expected to be rare and did not block the fix. It is not fixed yet. A fix would need the skip step to account for quote state without letting a stray quote swallow the file again.
