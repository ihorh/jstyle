# 0001: Keep newlines inside quoted fields, and bound the damage from a stray quote

Status: accepted, merged 2026-10-02, ships in 0.4.0. Discussed in issue #42.

## Context

Before 0.4.0, `read_row()` ended a row at the first `\n` and ignored quotes. That was a deliberate choice in 0.1. If the reader tracks quotes, one stray `"` makes it treat the rest of the file as a single field. The authors preferred "never swallow the file" over "handle quoted newlines".

The cost showed up in #42. A CRM export had a `notes` column with line breaks inside quoted fields, which RFC 4180 allows. splitlane cut those records in two, and the second half had the wrong number of columns. The downstream importer rejected the whole chunk. Two teams (billing and support analytics) were blocked. Neither had ever seen a malformed quote in their data.

Plain quote tracking was implemented first and hit the original worry. A test file of 400k rows with one stray `"` in row 12 produced a chunk with a header and one enormous row.

## Decision

`read_row()` tracks quotes, so a newline inside quotes stays in the row. The `--max-row-bytes` limit (default 65536) bounds the damage from a stray quote:

- When a row grows past the limit, `read_row()` stops, cuts the row there, and skips ahead to the next newline. Reading then continues normally.
- `read_row()` returns a flag saying the row was truncated.
- `split_file()` counts truncated rows, and the CLI prints the count to stderr at the end of a run, so a shortened row is never silent.

## Alternatives considered

- **Keep splitting at every newline.** This is safe against a stray quote, but it breaks every valid multi-line field. We rejected it because valid multi-line fields look more common in real exports. We have no data either way. The reporters have never seen a malformed quote.
- **Quote tracking with no bound.** Rejected after the 400k-row test above.
- **Treat a quoted field as broken after N lines.** Rejected because a legitimate note can have many lines. A byte limit separates the two cases better, and the option already existed.

## Consequences

- Valid multi-line fields now come through intact. The output file format does not change.
- A stray quote still damages data, but only up to the point where the limit is hit. The rest of the file is kept.
- This is our inference from reading `read_row()`, and we have not tested it. The truncated row holds everything from the stray quote up to the limit, so any short rows in that span are absorbed into it. Up to roughly `--max-row-bytes` of input can be lost per stray quote, which may be more than one row. The issue discussion described it as "one damaged row".
- Callers who need to detect this must check the truncation flag (library) or the stderr count (CLI). The importer in #42 will not notice a shortened row on its own.

## Known limitation

After a truncation, the skip goes to the next newline whether or not that newline is inside quotes. The reader can therefore resume in the middle of a real multi-line field and read its tail as a new row. This was raised on 2026-10-03, judged rare, and left unfixed. A fix has to decide what counts as a safe resync point when the quote state is already unreliable.
