Hi Sam, here's where #42 stands, since you're taking over tomasz's open follow-up (the thread is `issues/42-quoting.md`).

**Background.** maya reported that a quoted field containing a newline was split into two rows. devi fixed it in `read_row()` (`src/splitlane/split.py`) by tracking quotes. Her first version had a problem: one stray `"` in row 12 of a 400k-row file made the reader treat everything after it as a single field. So the merged version limits the damage. A row that grows past `--max-row-bytes` (default 65536) is cut there, counted as truncated, and the reader skips ahead to resync. The CLI prints the truncated-row count at the end of a run, and library callers get a flag from `read_row()`. The issue is closed and the fix ships in 0.4.0. maya's team has agreed to check the CLI message in their scripts.

**The follow-up.** tomasz raised it on 2026-10-03 and called it "probably rare, not blocking". After a truncation, the skip goes to the next `\n` whether or not that newline is inside quotes (`split.py:24-28`). The reader can therefore resync in the middle of a real multi-line field. Nobody has taken it on since.

**My reading of the code.** I haven't run any of this.
- The skip loop starts with quote state reset and doesn't track quotes. After a mid-field resync, the leftover lines of that field come out as extra rows. If one of those lines has a closing `"`, the next `read_row()` call takes it as an opening quote and can swallow rows up to the limit again.
- A stray quote costs more than "one row". The truncated row contains everything from the stray quote up to 64 KB later, so many real rows can merge into one damaged row. This is my inference, not something the thread states, so check it before you rely on it.

**Suggestions.**
- Write a failing test first. Use a legit multi-line field longer than `--max-row-bytes`, followed by normal rows.
- Decide what a good resync means. One option is to stop at the next newline that follows an even number of quotes since the skip began. That is harder to define when the cut landed inside a quoted field.
- Keep `read_row()` reading one character at a time, and don't change the `--max-row-bytes` default. devi's draft agent rules (`docs/agent-rules-draft.md`) ask for both.
- Add a changelog line only if behavior changes.

**Release context.** 0.4.0 is held up by #57, a Windows-only crash, not by #42. Priya owns the ship/hold decision. A fix for this follow-up isn't required for the release unless devi says otherwise, so ask her.
