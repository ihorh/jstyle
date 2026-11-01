# 0001: Keep newlines inside quoted fields, bounded by `--max-row-bytes`

- **Status:** Accepted. Merged 2026-10-02, ships in 0.4.0.
- **Issue:** #42
- **Code:** `read_row()` and `split_file()` in `src/splitlane/split.py`, plus the truncation warning in `src/splitlane/cli.py`

## Context

splitlane splits a CSV into chunks, and each chunk repeats the header. To do that it has to know where each row ends.

Up to 0.3.x, `read_row()` ended a row at the first `\n` and ignored quotes. This was a deliberate choice in 0.1. A reader that tracks quotes can be thrown off by one malformed quote: it then treats the rest of the file as a single field. The 0.1 rule was "never swallow the file," even if that meant quoted newlines weren't handled.

That rule broke real files. RFC 4180 allows line breaks inside quoted fields, and CRM exports with a free-text `notes` column often contain them:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

This input has two data rows, but splitlane wrote three. The extra row had the wrong number of columns, and the downstream importer rejected the whole chunk. Two internal teams, billing and support analytics, were blocked on this. Neither had ever seen a malformed quote in their exports.

The first fix was plain quote tracking. In testing, one stray `"` in row 12 of a 400k-row file made the reader treat everything after it as one field. The output was a chunk with a header and one enormous row, which is exactly the failure the 0.1 design was meant to prevent. Plain quote tracking was rejected for that reason.

## Decision

1. **Track quotes.** `read_row()` toggles an `in_quotes` state on every `"`. A `\n` ends the row only when it is outside quotes, so quoted newlines stay in the field, as RFC 4180 specifies and spreadsheets do.

2. **Bound every row with `--max-row-bytes`** (default 65536, measured as UTF-8 bytes). If a row grows past the limit, the reader:
   - stops and keeps what it has read so far as the row,
   - throws away input up to the next `\n` (or the end of input), and
   - marks the row as truncated.

   A legitimate multi-line field stays far below the limit. A stray quote reaches the limit, damages that one row, and the reader picks up again on the next line. The worst case is one damaged row, not a swallowed file.

3. **Never truncate silently.**
   - Library: `read_row()` returns `(row, truncated)`. `split_file()` returns `(written_paths, truncated_count)`.
   - CLI: at the end of a run, if any rows were truncated, it prints this to stderr:
     `splitlane: warning: N row(s) longer than M bytes were truncated`.
     The exit status stays 0. Callers who need to catch truncation should look for this warning. The billing and support analytics scripts do.

## Alternatives considered

- **Keep the 0.1 behaviour and ignore quotes.** Rejected. It breaks valid RFC 4180 input that is common in practice, while the failure it guards against seems rare.
- **Plain quote tracking with no bound.** Rejected. One stray quote can turn the rest of the file into a single row, as the 400k-row test showed.
- **Treat a quoted field as broken after N lines.** Rejected. A notes field can legitimately have many lines, so no line count separates good fields from bad ones. A byte limit does, and `--max-row-bytes` already existed (added in 0.3.0).

## Consequences

- Valid multi-line quoted fields now come through as one row.
- A malformed quote costs one truncated row, and the run reports it.
- A legitimate row longer than `--max-row-bytes` is also truncated, whether or not it has quoted newlines. Users with very large fields need to raise the limit.
- The truncated row is written cut off at the limit. It may have the wrong number of columns or an unclosed quote. splitlane counts it but doesn't repair or drop it.
- The truncated-row count reported by the CLI and `split_file()` covers data rows only. If the header itself is truncated, it isn't counted.

## Known limitation (follow-up, not blocking)

After a truncation, the reader skips to the next `\n` **without tracking quotes**. If that newline is inside a real multi-line quoted field, the reader picks up in the middle of the field and can misread the rows after it. This should be rare. It was noted in #42 as a later follow-up and was not fixed in 0.4.0. Anyone changing the skip logic in `read_row()` should keep in mind that the skip has to stay bounded, or the "never swallow the file" guarantee is lost.
