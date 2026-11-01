**Subject: Taking over the open follow-up on #42 (resync after truncation)**

Hi Sam, here's the background on #42 and the follow-up you're picking up from tomasz.

**What #42 was**
- Maya's CRM export has a `notes` column with line breaks inside quoted fields.
- splitlane's `read_row()` ended a row at the first `\n` and ignored quotes. One customer became two broken rows, and Maya's importer rejected the whole chunk.
- Devi had left quotes untracked on purpose in 0.1. Tracking them means one stray `"` can make the reader treat the rest of the file as one field.
- Devi's test confirmed this. One stray quote in row 12 of 400k rows produced a chunk with a header and one enormous row.

**What was decided and merged (2026-10-02)**
- `read_row()` now tracks quotes, so a newline inside quotes stays in the row.
- The tracking is bounded by `--max-row-bytes`. When a row passes that limit, it is cut there, counted as truncated, and the reader skips ahead to the next newline.
- A stray quote now damages one row instead of swallowing the file.
- Truncation is reported. The CLI prints a warning with the count at the end of a run, and library callers get a flag from `read_row()`. Maya's team will check for that message in their scripts.
- Devi closed the issue. The fix ships in 0.4.0.

**The follow-up you now own**
Tomasz noted it on 2026-10-03 and called it probably rare and not blocking. After truncation, the skip goes to the next `\n` even if that newline is inside quotes. In a bad case the reader could resync in the middle of a real multi-line field, so that field would be split or misread.

The code matches this. The skip loop is in `src/splitlane/split.py`, in `read_row()`, at lines 24–29. It reads to the next `\n` and has no notion of quotes.

Nobody has reproduced the problem or written a test for it yet. A first step would be a test with a stray quote followed by a legitimate multi-line field. That would show how likely it is and what a fix needs to do.

**Where 0.4.0 stands**
- Everything in the changelog is merged, but 0.4.0 isn't out yet. Priya owns the release decision.
- #57 is a Windows-only blocker. A chunk file left open in Excel makes splitlane crash with `PermissionError` partway through, and the error doesn't say which chunks were written. The proper fix touches every write path.
- Priya is choosing between shipping now with a known-issue note for Windows and holding until #57 is fixed. Billing and support analytics are waiting on the #42 fix, and both run on Linux.
- The resync follow-up wasn't treated as a release blocker. Please don't treat it as one unless your repro shows it's more common than expected.

**Files to look at**
- `issues/42-quoting.md` has the full thread.
- `notes/release-status.md` has Devi's release notes.
- `CHANGELOG.md` lists what's in 0.4.0.
