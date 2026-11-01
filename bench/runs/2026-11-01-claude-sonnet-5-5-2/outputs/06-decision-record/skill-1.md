I couldn't write the file because the Write tool is disabled in this session. The content for `docs/decisions/0001-quoted-newlines.md` is below.

# 0001: Keep newlines inside quoted fields, and bound the damage from a stray quote

Status: accepted, merged 2026-10-02 (issue #42), ships in 0.4.0.

## Context

Up to 0.3, `read_row()` in `src/splitlane/split.py` ended a row at the first `\n` and ignored quotes. This was deliberate. If the reader tracks quotes, one unmatched `"` makes it believe the rest of the file is a single field, so a bad byte can swallow the whole input. The original choice was "never swallow the file" over "handle quoted newlines".

The cost showed up in issue #42. CSV exports with a free-text column (a CRM `notes` field) contain line breaks inside quoted fields, which RFC 4180 allows. splitlane cut those records in two, and the downstream importer rejected the whole chunk. Two internal teams (billing and support analytics) were blocked on it, and neither had ever seen a malformed quote in their data.

The first implementation, plain quote tracking, was tested on a 400k-row file with one stray `"` in row 12. It wrote a chunk with a header and one enormous row, which is the failure the 0.1 design was meant to prevent. So quote tracking alone was rejected.

## Decision

`read_row()` tracks quotes, so a newline inside quotes stays in the row. The tracking is bounded by `--max-row-bytes` (default 65536):

- When a row grows past the limit, the reader stops and returns the row cut at that point.
- It then skips ahead to the next newline, whether or not that newline is inside quotes, and reading resumes from there.
- The cut row is reported as truncated. `read_row()` returns `True` as the second element of its result, and the CLI prints the number of truncated rows at the end of a run.

A legitimate multi-line field is far below the limit. A stray quote now damages a bounded amount of input instead of the rest of the file.

## Alternatives considered

- **Keep splitting at every newline (the 0.1 behavior).** Safe against stray quotes, but it breaks valid RFC 4180 files, which is what the reporters have.
- **Track quotes with no bound.** Correct for valid files, but one stray quote swallows the rest of the input. This was tested and rejected.
- **Treat a quoted field longer than N lines as broken.** Rejected because a notes field can legitimately span many lines. Size is a better signal than line count.

## Consequences

- Valid multi-line fields now stay in one row. Truncation is not silent: anyone who feeds splitlane output to a strict importer should check the truncated-row count the CLI prints. The #42 reporters agreed to check for it in their scripts.
- A truncated row is shortened, so its data is lost. A legitimate field larger than `--max-row-bytes` is cut the same way, and the fix for that is a larger limit.
- Do not raise the `--max-row-bytes` default to make a test pass. The default is what keeps a stray quote cheap.
- Known gap, raised by tomasz after the merge and not fixed: the skip after truncation stops at the next newline even if that newline is inside a real quoted field, so the reader can resume in the middle of a valid multi-line field. It is probably rare, and it was judged not to block the release.
- Our inference from reading the code, not tested: after a stray quote, the reader keeps absorbing following rows until the row passes the limit. A stray quote can therefore cost up to roughly `--max-row-bytes` of following rows, which may be several rows, not exactly one.
