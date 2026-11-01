Hi Sam, here's where tomasz's follow-up on #42 stands, so you don't need to read the thread.

**The original bug.** Maya reported that splitlane split a row in two when a quoted field had a line break in it. This was common in CRM exports with a `notes` column. In 0.1, `read_row()` ignored quotes and ended a row at the first `\n`. Devi did that on purpose: if the reader tracks quotes, one stray `"` can make it treat the rest of the file as a single field. Devi tried quote tracking and hit exactly that: one bad quote in row 12 of a 400k-row file turned everything after it into one huge row.

**What got merged (ships in 0.4.0).** Devi merged it on 2026-10-02:
- `read_row()` now tracks quotes, so a newline inside quotes stays in the field (`src/splitlane/split.py:18-21`).
- The quote tracking has a limit. If a row grows past `--max-row-bytes` (default 64 KiB), the reader cuts it there, marks it truncated and skips ahead to the next newline (`split.py:23-29`).
- Truncated rows are counted, and the CLI prints a warning at the end of the run (`cli.py:34-36`). Library callers get a flag back from `read_row()`.

**Your follow-up.** tomasz noticed that the skip after a truncation stops at the next `\n` even when that newline is inside quotes, so the reader can pick up again in the middle of a real multi-line field. They called it "probably rare, not blocking."

From reading the code, I think a bad case could be worse than one bad row. I haven't tested this. The next `read_row()` call starts with `in_quotes = False`. If it starts partway through a quoted field, it will read that field's closing `"` as an opening quote. It could then run to the byte limit and truncate again, possibly more than once before it gets back in step. Each step is still bounded, so it can't swallow the file, but it may damage more rows than the one warning suggests. A good first step would be a test that reproduces this: a stray quote followed soon after by a real multi-line notes field.

**Things to keep in mind:**
- Billing and support analytics (Maya's teams) are blocked on the #42 fix and are waiting for 0.4.0. Their scripts check for the truncation warning in the CLI output, so don't change the wording without telling them. The exit code is still 0 when rows are truncated.
- 0.4.0 itself is blocked on #57, a Windows-only crash when a chunk file is open in Excel (`notes/release-status.md`). Priya decides whether to ship now or hold. Your follow-up isn't part of that decision, and nobody has asked for it in 0.4.0.
- Devi wrote the reader and knows the reasons behind its design best. Talk to them before you change how it recovers after a truncation.
