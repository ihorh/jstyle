I couldn't write `docs/decisions/0001-quoted-newlines.md` because the Write tool is disabled in this session. The content is below, ready to save as that file.

````markdown
# 0001: Keep newlines inside quoted fields, bounded by `--max-row-bytes`

- Status: accepted, merged 2026-10-02, ships in 0.4.0
- Issue: #42
- Deciders: devi, tomasz

## Context

splitlane splits a CSV into chunks of N rows, repeating the header in each
chunk. To do that it has to find where a row ends, and `read_row()` in
`src/splitlane/split.py` does this itself instead of using the `csv` module.

Through 0.3.x, `read_row()` ended a row at the first `\n` and ignored quotes.
That was deliberate. If the reader tracks quotes, one malformed quote (a stray
`"`) makes it treat the rest of the file as a single field. Ignoring quotes
guaranteed that a bad row could never swallow the file.

The cost is that RFC 4180 allows a newline inside a quoted field, and real
exports use it. A CRM export with a multi-line `notes` column came out as
broken rows with the wrong column count, and the downstream importer rejected
the whole chunk. Two internal teams (billing and support analytics) were
blocked on this.

So there were two failures to choose between:

- Not tracking quotes splits every legitimate multi-line field in two.
- Tracking quotes lets a single stray quote destroy everything after it.

## Decision

`read_row()` tracks quotes, so a newline inside quotes stays in the row. The
tracking is bounded:

- If a row grows past `--max-row-bytes` (default 65536), the reader stops
  and returns what it has, flagged as truncated.
- It then skips ahead to the next newline and resumes reading rows from there.
- The limit is in bytes, not lines. A legitimate note can have many lines, so
  counting lines would reject valid data.

Truncation is reported, not silent:

- `read_row()` returns `(row, was_truncated)`. Library callers get the flag.
- `split_file()` returns the count of truncated rows.
- The CLI prints `warning: N row(s) longer than <limit> bytes were truncated`
  to stderr at the end of a run. Callers who script around splitlane (the
  billing and support teams do) should check for this message.

## Consequences

- Valid RFC 4180 files with multi-line fields now split correctly.
- A stray quote damages one row, not the rest of the file. Test case from the
  discussion: one stray `"` in row 12 of 400k rows. Without the bound,
  everything after row 12 became one huge row in one chunk.
- A truncated row is still written to the output, cut off at the limit, so it
  likely has an unterminated quote and the wrong column count. A downstream
  importer will not necessarily notice. This is why the CLI reports the count.
- A legitimate field larger than `--max-row-bytes` is also truncated. The fix
  is to raise the limit for that run. Do not change the default to make a
  failing test pass.

## Known gap

After truncation, the skip goes to the next newline whether or not that
newline is inside quotes. In a bad case, the reader can resume in the middle
of a real multi-line field and produce one more damaged row before it
resynchronizes. This is believed to be rare, and it was judged not worth
blocking the fix. It has not been addressed. If you change the resync logic,
take care not to bring back the "swallow the rest of the file" failure.

## Alternatives considered

- **Keep ignoring quotes (the 0.1 behavior).** Safe, but it breaks valid files
  that two teams depend on. Rejected.
- **Track quotes with no bound.** Correct on well-formed input, but one stray
  quote swallows the file. This was implemented and tested, and it failed the
  400k-row test above. Rejected.
- **Treat a quoted field as broken after N lines.** Rejected because
  legitimate fields can span many lines. A byte limit is a better proxy for
  "this is not a real field", and the option already existed.
- **Use the `csv` module to find row boundaries.** Not discussed in the
  issue. Its behavior on an unterminated quote was not evaluated, and it
  would not give us the truncation bound described above. If you revisit this,
  start by checking how it handles an unterminated quote.
````
