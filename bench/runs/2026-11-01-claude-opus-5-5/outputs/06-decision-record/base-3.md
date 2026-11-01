# 0001: Keep quoted newlines inside the row, bounded by `--max-row-bytes`

- **Status:** Accepted. Merged 2026-10-02; ships in 0.4.0.
- **Issue:** #42
- **Code:** `read_row()` in `src/splitlane/split.py`

## Context

Fields in a CSV file can contain line breaks if the field is quoted (RFC 4180). CRM exports often do this in free-text columns such as `notes`:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

This has two data rows. Through 0.3.x, `read_row()` ended a row at the first `\n` and ignored quotes, so splitlane wrote three rows here. The second of those rows had the wrong number of columns, and downstream importers rejected the whole chunk. Two internal teams (billing and support analytics) were blocked on this.

Ignoring quotes in 0.1 was a deliberate choice. Once a reader tracks quotes, one stray or unterminated `"` makes it treat everything after that point as a single field. A test of quote tracking alone confirmed the risk: a file with 400k rows and one stray `"` in row 12 produced a chunk with the header and one enormous row. The 0.1 rule was "never swallow the file," even if quoted newlines broke as a result.

Line counting was suggested as a way to spot a runaway quote ("a quoted field longer than N lines is broken"). It was rejected because a real notes field can have many lines.

## Decision

1. `read_row()` tracks quotes. A `\n` inside a quoted field stays in the field, and only a `\n` outside quotes ends the row.
2. The existing `--max-row-bytes` limit (default 65536) caps how far a row can grow. Real multi-line fields stay well under the limit, and a runaway quote reaches it. When a row passes the limit:
   - the row is cut at the limit, and the cut row is still written to the chunk;
   - the reader skips ahead to the next `\n`, or to end of input, and starts the next row there with quote state reset;
   - the row is reported as truncated.
3. Truncation is never silent:
   - `read_row()` returns `(row, truncated)`, and `split_file()` returns the count of truncated rows along with the list of written files.
   - At the end of a run the CLI prints to stderr: `splitlane: warning: N row(s) longer than M bytes were truncated`. Users who reported #42 check for this message in their scripts, so don't change its wording casually.

In short: quoted newlines are handled correctly, and a malformed quote damages a bounded part of the input instead of everything after it.

## Consequences

- Correct RFC 4180 input with multi-line quoted fields now splits correctly.
- A stray quote still causes data loss, but the loss is bounded and reported. The bound is in bytes, not rows. Every line after the stray quote, up to `--max-row-bytes`, goes into one cut output row. With short rows, that can be hundreds of input rows merged into one bad row. The cut row usually also has an unterminated quote, so downstream parsers may reject it.
- `--max-row-bytes` now does two jobs: it is the longest legitimate row kept whole, and it is the blast radius of a malformed quote. A higher value lets longer legitimate rows through but loses more data on a bad quote, and a lower value does the reverse. Don't change the default without weighing both.
- `read_row()` reads one character at a time and toggles quote state on every `"`. An escaped quote (`""`) toggles twice and so leaves the state unchanged, which is correct.

## Known limitations

- **Resync can land inside a real quoted field.** After a truncation, the skip goes to the next `\n` whether or not that newline is inside quotes. If it lands in the middle of a legitimate multi-line field, the reader resyncs wrong and the following row(s) may be damaged too. This came up after merge and was judged rare and not blocking. It is the obvious follow-up if truncation problems are reported.
- **A truncated header is not reported.** `split_file()` throws away the truncation flag for the header row (`header, _ = read_row(...)`), so a header longer than `--max-row-bytes` is cut without a warning.

## Alternatives considered

- **Keep ignoring quotes (0.1 behavior).** Rejected. It breaks common, valid exports, and the people who reported #42 had never seen a malformed quote in practice.
- **Unbounded quote tracking.** Rejected. One stray quote swallows the rest of the file, as shown in testing.
- **Treat a quoted field longer than N lines as broken.** Rejected. Legitimate fields can have many lines, and a byte limit already existed.
