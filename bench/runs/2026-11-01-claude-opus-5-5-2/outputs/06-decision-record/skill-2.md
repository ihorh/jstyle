# 0001: Keep quoted newlines inside the row, and cap runaway rows at `--max-row-bytes`

- **Status:** Accepted. Merged on 2026-10-02, ships in 0.4.0.
- **Issue:** #42
- **Discussed by:** maya (reported it for the billing and support analytics teams), devi, tomasz

## Context

RFC 4180 lets a quoted CSV field contain a line break. CRM exports use this for free-text columns such as `notes`:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

This input has two data rows. Up to 0.3.x, `read_row()` ended a row at the first `\n` and ignored quotes, so splitlane wrote three rows here. The second of those rows had the wrong number of columns, and the downstream importer rejected the whole chunk. This blocked two teams.

Ignoring quotes was a deliberate choice in 0.1. If the reader tracks quotes, one stray `"` makes it treat the rest of the file as a single field. That risk turned out to be real. devi's first implementation was given a 400k-row file with a stray quote in row 12. It read everything after row 12 as one field and wrote a chunk containing a header and one enormous row.

So both simple options fail on real input:

- **Ignore quotes:** every legitimate multi-line field breaks.
- **Track quotes with no limit:** one malformed quote swallows the rest of the file.

## Decision

`read_row()` tracks quotes, and a newline inside quotes stays in the field. The existing `--max-row-bytes` limit (default 65536) bounds how far one row can grow:

1. When a row passes the limit, the reader stops and keeps what it has read so far as the row.
2. It discards input up to the next newline, or to the end of input, and resumes reading from there.
3. It reports the row as truncated.

A legitimate multi-line note stays far below the limit. A stray quote reaches the limit, damages one row, and the reader recovers at the next line. One damaged row is a much smaller failure than a swallowed file.

We rejected detecting a stray quote by counting lines in a quoted field, because a legitimate notes field can span many lines.

## Truncation is reported, not silent

A truncated row is shorter than the original, and an importer won't notice that on its own. So truncation is always reported:

- **Library:** `read_row()` returns `(row, truncated)`, and `split_file()` returns `(written_files, truncated_count)`.
- **CLI:** at the end of a run, it prints this to stderr:

  ```
  splitlane: warning: N row(s) longer than MAX bytes were truncated
  ```

The exit status stays 0 when rows were truncated. The teams that requested the fix check for this warning in their scripts, so treat its wording as an interface. If you change it, say so in the changelog.

## Consequences

- Quoted newlines from spreadsheets and CRM exports now survive splitting.
- A malformed quote costs one row instead of the rest of the file. The CLI warning reports it, but the run still succeeds.
- Any row longer than `--max-row-bytes` is truncated, whether or not a stray quote caused it. If your data has legitimately long rows, raise the limit.
- The truncated row is still written to its chunk, cut off partway. It can therefore have too few columns or an unclosed quote. (This is my reading of `read_row()` in `src/splitlane/split.py`. The issue thread doesn't discuss it.)

## Known limitation

After truncating a row, the reader skips to the next newline even when that newline is inside quotes. If the skip lands in the middle of a real multi-line field, the reader resumes mid-field with its quote state reversed. That can damage the rows that follow until the reader resyncs. tomasz raised this on 2026-10-03 as a follow-up. It's probably rare, so it didn't block the release, and it has no issue of its own yet.
