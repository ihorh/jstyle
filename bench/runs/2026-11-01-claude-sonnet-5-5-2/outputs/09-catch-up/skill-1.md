Sam, here's the background on the #42 follow-up you're taking over from tomasz.

**Background.** Issue #42 was maya's report that splitlane split CSV rows whenever a quoted field contained a newline. That broke their CRM export, and billing and support analytics were blocked on it. devi made `read_row()` in `src/splitlane/split.py` track quotes, so a newline inside quotes stays in the row. Her first version had a problem. A single stray `"` in a 400k-row file made the reader treat everything after it as one field. The fix is a bound: once a row passes `--max-row-bytes` (default 65536), the reader cuts the row there, counts it as truncated, and skips ahead to the next newline. The CLI prints the truncated-row count at the end of a run, and `read_row()` returns a flag for library callers. This was merged on 2026-10-02, the issue was closed, and the fix is in the Unreleased 0.4.0 section of the changelog.

**The follow-up.** tomasz's comment on 2026-10-03 reads: "the skip after truncation goes to the next newline even if that newline is inside quotes. So in a bad case, the reader might resync in the middle of a real multi-line field. Probably rare. Not blocking."

The skip loop is at `src/splitlane/split.py:24-29`. It reads characters until the first `\n` and ignores quotes. I checked it against the code and it behaves as tomasz described. Nobody has written a fix, a test, or a reproduction.

**Things to know before you start:**
- **Why a quote-aware skip may not be the answer.** After a stray quote, the reader's quote state is wrong, so every later newline looks like it's inside quotes. The plain skip to the next newline is what recovers from that case. Making the skip quote-aware could bring back the swallowed-file failure that devi's bound was added to prevent. The case to guard against is a truncated row that was a legitimate long multi-line field. Decide how to handle that before you change the skip.
- **My inference, not from the thread:** the truncated row is written out with whatever quote state it had at the cut. It can end with an unclosed `"` in the output chunk. I haven't checked whether maya's importer chokes on that, so it may be worth asking her.
- **Release.** This isn't a release blocker. The 0.4.0 decision is waiting on #57 (Windows only: a `PermissionError` when overwriting a chunk that's open in Excel). Priya owns that decision, and devi's notes are in `notes/release-status.md`.
- **Constraints.** `docs/agent-rules-draft.md` is devi's draft rules for coding agents. It asks that you keep `read_row()` from getting slower, send all messages to stderr, and add a changelog line for any behavior change.

**Suggested first step.** Write a test file with a truncated row followed by a quoted multi-line field. Then decide with devi whether the case is worth the added complexity. tomasz's own estimate was that it's rare, and closing it as "won't fix, documented" is a reasonable outcome.
