I've written the catch-up message for Sam, below. I read the #42 thread, `split.py`, the changelog and the release notes. I also had a fresh reader go over a draft as Sam would, then clarified the parts it got stuck on: what a truncated row keeps, who everyone is, and what's actually being asked.

The section on what could go wrong is my own reading of the code. Nobody in the thread said it and I haven't tested it, and the message tells Sam that.

---

Hi Sam,

Here's the background on the #42 follow-up you're taking over from tomasz. The full thread is in `issues/42-quoting.md`. For orientation: maya reported the bug for the teams that depend on splitlane, devi wrote the fix, and tomasz reviewed it.

**What #42 was about.** maya reported that splitlane split one row into two when a quoted field contained a line break. CRM exports have these in their `notes` column. Two teams that use splitlane, billing and support analytics, are waiting on the fix. Before #42, `read_row()` ignored quotes on purpose. devi worried that tracking quotes would let one stray `"` turn the rest of the file into a single field. When devi tried quote tracking on a test file with one stray quote, that is what happened.

The fix merged on 2026-10-02. It tracks quotes but puts a cap on how long a row can get. `read_row()` counts the row's size in UTF-8 bytes. If the row goes past `--max-row-bytes` (default 65536), it keeps what it has read so far, throws away everything up to the next newline, and returns the row flagged as truncated. At the end of a run, the CLI prints `splitlane: warning: N row(s) longer than 65536 bytes were truncated` to stderr. maya's teams check for that warning in their scripts. So a stray quote now damages one row instead of the rest of the file. The fix will ship in 0.4.0.

**The follow-up.** In the last comment on #42, tomasz pointed out a gap: after truncation, the skip goes to the next newline even when that newline is inside quotes. The code is at `src/splitlane/split.py:23-29`. The skip loop stops at the first `\n` it finds, and the next call to `read_row()` starts with `in_quotes = False`. So if the first newline after the 65536-byte mark sits inside a real multi-line field, the reader picks up again in the middle of that field. tomasz guessed this is rare and said it doesn't block anything. Nobody has defined the work beyond that comment, and the follow-up has no issue of its own because #42 is closed. I'd open one, write a test that reproduces it, and then decide on a fix with devi.

**What I think could go wrong.** This is my reading of the code. It isn't from the thread, and I haven't tested it. Once the reader picks up mid-field, it takes that field's closing `"` as an opening quote. From then on it treats real row breaks as newlines inside quotes, so it glues the following rows together until it reaches another `"`. If that quote comes before the byte limit, the merged row gets written out without being counted as truncated, and the warning never mentions it. maya's teams rely on that warning, so this is the case I'd test first.

A separate point: the truncated row itself goes into the chunk as it is, and it can end inside an open quote. The importer maya's teams use might misread it. I don't know how that importer handles an unclosed quote.

**Before you change it.**
- `read_row()` reads one character at a time. In `docs/agent-rules-draft.md`, devi asks that it not get any slower. That file is a draft, and as far as I can tell there's no benchmark.
- 0.4.0 hasn't shipped. It's held up by #57, a crash that only happens on Windows. Priya owns the release and is deciding whether to ship anyway (`notes/release-status.md`). This follow-up isn't part of that decision.
