Hi Sam, here's the context for tomasz's open follow-up on #42.

**Background**
- Maya reported that splitlane split CSV rows at newlines inside quoted fields, which broke her CRM exports (the `notes` column). Billing and support analytics were blocked on it.
- Devi made `read_row()` in `src/splitlane/split.py` track quotes, so a newline inside quotes stays in the row.
- Devi found that a single stray `"` made the reader swallow the rest of the file as one field. That was the reason for the original newline-only behavior in 0.1.
- To bound the damage, a row that grows past `--max-row-bytes` is cut there and counted as truncated. The CLI prints the truncated-row count at the end of a run, and `read_row()` returns a flag for library callers. Maya's team will check for that message in their scripts.
- Devi merged this on 2026-10-02 and closed the issue. It's in the Unreleased (0.4.0) section of the changelog. It hasn't shipped, because 0.4.0 is on hold pending the release decision about the Windows bug #57 (`notes/release-status.md`).

**The follow-up**
Tomasz noted on 2026-10-03 that after truncation, `read_row()` skips ahead to the next newline even if that newline is inside quotes. If that happens inside a real multi-line field, the reader could resume in the middle of that field. Tomasz called it probably rare and not blocking. The skip loop is at `split.py:24-28` and ignores quotes on purpose.

**My reading of the code (not confirmed with Tomasz or Devi)**
- For the stray-quote case the current behavior is probably right. The reader is already in a broken state, and the next raw newline is the best place to resync.
- The bad case is a legitimate quoted field longer than `--max-row-bytes`, which is 65536 by default. The skip stops at a newline inside that field, and the rest of the field gets parsed as new rows. Those rows would have the wrong number of columns, and the quote parity could be flipped from there on.
- I couldn't find any tests in the repo, so none cover this path.

**Next steps**
- Reproduce the case with a legitimate multi-line field larger than the limit, and see what comes out.
- Decide whether the skip needs to be quote-aware. Any change has to keep the guarantee Devi cared about, that a stray quote damages one row and never the whole file.
- Check with Devi before changing the truncation behavior, since the CLI message and the library flag are already promised to Maya's team.
