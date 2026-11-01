Hi Sam, here's the background on tomasz's open follow-up on #42.

**What #42 was**
maya reported that splitlane split rows whose quoted fields contain newlines. A CRM `notes` column is one example. Billing and support analytics were blocked on it.

**What was decided and shipped**
- `read_row()` now tracks quotes, so a newline inside quotes stays in the row.
- devi found that one stray `"` made the reader swallow the rest of the file. She tested it with a stray quote at row 12 of 400k rows.
- The fix is to bound the damage with `--max-row-bytes`. A row that grows past the limit is cut there and counted as truncated. The reader then skips ahead and carries on.
- The CLI prints the truncated-row count at the end of a run. Library callers get a flag from `read_row()`. maya's team will check for the CLI message in their scripts.
- devi merged this on 2026-10-02 and closed the issue. It is in the Unreleased (0.4.0) changelog.

**The open follow-up (tomasz, 2026-10-03)**
After truncation, the skip goes to the next `\n` even if that newline is inside quotes. It's at `src/splitlane/split.py:24-28`, and the comment there says "quoted or not". If a stray quote forces a truncation, the reader may resume in the middle of a real multi-line field.

My reading of the code, which I haven't run: the next `read_row()` call starts with `in_quotes = False`. The closing quote of that half-read field would then flip it to "inside quotes". The next row's newline could then be swallowed until another quote shows up, or until the limit is hit again. So one bad quote could damage more than one row. It would still be bounded, not a swallowed file.

tomasz called it probably rare and not blocking. Nobody has measured how often it happens, and nobody has reproduced it or written a test for it. No fix has been proposed or agreed.

**Things to know**
- The truncated-row count gives some visibility, but it counts truncation events, not damaged rows. If the cascade above is real, the count would understate the damage.
- 0.4.0 isn't out yet. Priya is deciding whether to ship now or wait for #57, a Windows-only crash on overwriting chunks that are open in Excel (`notes/release-status.md`). The #42 fix is already merged either way.
- devi's draft agent rules (`docs/agent-rules-draft.md`) say to keep `read_row()` fast, so don't make it slower. Don't change the `--max-row-bytes` default (65536) either.

**Suggested first steps**
1. Write a failing test: a file with a stray quote, followed by a legit multi-line quoted field, and check what comes out.
2. If it confirms the cascade, raise a fix with devi before changing `read_row()`.
