Hi Sam, here's where #42 stands and what the follow-up you're picking up from tomasz involves.

**The original bug.** Maya reported that splitlane split CRM exports wrongly. When a quoted field contained a line break (like a multi-line `notes` column), `read_row()` ended the row at that line break. One record became two broken rows, and the importer downstream rejected the whole chunk. Two teams are blocked on this: billing and support analytics.

**Why it was built that way.** In 0.1, devi chose to ignore quotes on purpose. If the reader tracks quotes, one stray `"` can make it treat the rest of the file as a single field. When devi tried plain quote tracking on a branch, that's exactly what happened: one stray quote in row 12 of 400k rows turned everything after it into one enormous row.

**What got merged (2026-10-02).** Quote tracking is in, but `--max-row-bytes` (default 64 KiB) limits how far it can go:
- A newline inside quotes stays in the field.
- If a row grows past the limit, it's cut at the limit and counted as truncated. The reader then skips ahead to the next newline and carries on.
- The CLI prints the truncated-row count at the end of each run, and `read_row()` returns a flag for library callers. Maya's scripts check that CLI message, so that count is how her teams find out data was lost.

The fix is in the Unreleased (0.4.0) section of `CHANGELOG.md`, but 0.4.0 hasn't shipped yet. It's blocked on #57, a Windows-only bug, and Priya decides whether to ship now or wait (see `notes/release-status.md`). Your follow-up doesn't block the release.

**Your follow-up.** After a truncation, the skip goes to the next newline *even if that newline is inside quotes* (`src/splitlane/split.py:24-29`). So if the truncation happens near a real multi-line field, the reader can pick up again in the middle of that field. tomasz thought this was probably rare and not blocking.

From reading the code, I think a bad resync costs more than one row, though I haven't tested this:
- The skip loop doesn't track quotes. After a mid-field resync, the reader's sense of what's inside quotes is reversed, so it can misread the rows that follow, or run into the byte limit again.
- The rows produced after a resync aren't flagged. Only the cut row is counted. That means the truncated count, which Maya's teams depend on, can understate the damage.

A good first step would be a test file with a stray quote just before a real multi-line note, to confirm or rule this out.

Background reading: `issues/42-quoting.md` has the full thread, and `notes/release-status.md` covers the release situation.
