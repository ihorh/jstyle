# 0001: Keep newlines inside quoted fields, bounded by `--max-row-bytes`

- Status: Accepted, ships in 0.4.0
- Issue: #42
- Code: `read_row()` in `src/splitlane/split.py`

## Context

A CSV field in double quotes can contain a line break. RFC 4180 allows this, and spreadsheets and CRM exports produce it, for example in a free-text `notes` column:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

Up to 0.3.x, `read_row()` ended a row at the first `\n` and ignored quotes. The example above came out as three data rows instead of two. The extra row had the wrong number of columns, and downstream importers rejected the whole chunk. Two internal teams, billing and support analytics, were blocked by this.

The 0.1 behavior was deliberate. If the reader tracks quotes, one stray or unterminated `"` makes it treat the rest of the file as a single field. We saw this happen in testing: one stray quote in row 12 of a 400k-row file gave a chunk with a header and one enormous row. The 0.1 design accepted wrong results on quoted newlines to avoid that failure.

We have no data on how often malformed quotes occur compared with real multi-line fields. The teams affected by #42 had never seen a malformed quote. Multi-line fields show up in their regular exports.

## Decision

1. `read_row()` tracks quotes. A `\n` inside a quoted field belongs to the field, and only a `\n` outside quotes ends the row.
2. `--max-row-bytes` (default 65536) limits how far a row can grow. When a row passes the limit, the reader:
   - cuts the row at the limit,
   - throws away input up to the next `\n`, or to the end of the file,
   - returns the cut row marked as truncated.

   The cut row is still written to the chunk.
3. Truncation is never silent:
   - `read_row()` returns a `(row, truncated)` pair.
   - `split_file()` returns the number of truncated rows.
   - The CLI prints `splitlane: warning: N row(s) longer than M bytes were truncated` to stderr at the end of the run. Users told us they check their scripts for this message, so treat its wording as an interface.

The limit works as a guard because a real multi-line field stays far below 64 KiB, while a stray quote reaches it quickly. A malformed quote then damages one row instead of the rest of the file.

## Alternatives considered

- **Keep 0.1 behavior and ignore quotes.** Rejected. Valid input gave wrong output, which blocked real users.
- **Track quotes with no limit.** Rejected. One stray quote swallows the rest of the file. This is the failure 0.1 was designed to avoid.
- **Treat a quoted field as broken after N lines.** Rejected. A notes field can legitimately span many lines, so no line count works for everyone. A byte limit fits better, and we already had the `--max-row-bytes` option.

## Consequences

- Valid files with quoted newlines now split correctly.
- A malformed quote costs one damaged row, which is cut short and probably has the wrong column count, plus a warning. Callers who need clean output should check the warning or the `truncated` flag and treat a nonzero count as a failure.
- Raising `--max-row-bytes` lets longer legitimate rows through, but a stray quote then consumes more of the file before the reader recovers. Lowering it can truncate real rows. Don't change the default to make a test pass.
- The header row goes through the same `read_row()` call, but `split_file()` ignores its truncation flag. A truncated header is not counted in the warning.

## Known limitation (open)

After a truncation, the reader skips to the next `\n` whether or not that newline is inside quotes, and it resets quote tracking there. If that newline falls inside a real multi-line field, the reader resyncs in the middle of the field and the following rows can be split wrongly. We expect this to be rare, and it did not block 0.4.0. A fix would need a smarter resync rule than "next newline". Any change to `read_row()` should also keep it at least as fast as it is now.
