**Sam, here's where #42 stands.**

**Background.** Maya reported that splitlane split CSV rows at newlines inside quoted fields. Their CRM export has a `notes` column with line breaks, so one customer became two broken rows and their importer rejected the chunk. Devi fixed it by tracking quotes in `read_row()` (`src/splitlane/split.py`). To avoid swallowing a whole file after a stray `"`, the row is cut at `--max-row-bytes` and counted as truncated. The CLI prints the truncated count at the end of a run. Library callers get a flag from `read_row()`. Devi merged this on 2026-10-02 and closed the issue. It's in the Unreleased (0.4.0) section of the changelog.

**Your follow-up.** Tomasz raised it on 2026-10-03 and marked it non-blocking. After a row is truncated, `read_row()` skips ahead to the next `\n` whether or not that newline is inside quotes. You can see this in the skip loop at `split.py:25-28`. In the bad case, the reader resyncs in the middle of a real multi-line field. The next row then starts mid-field and comes out as a garbled row. Tomasz guessed this is rare, but nobody has measured it. It's also not covered by a test or confirmed with a repro.

**Suggested first steps:**
1. Write a repro: a file with a stray quote followed by a legitimate multi-line quoted field, and a small `--max-row-bytes`. Check what the next row looks like.
2. Decide on the fix. The options I see are to resync only at a newline that's likely outside quotes, or to leave it as is and document it. I don't have a recommendation yet. Run it by Devi, who wrote the quote tracking and chose the truncation approach.
3. If behavior changes, add a changelog line. The skip is currently unchanged from the 0.1 behavior, so check whether it counts as user-visible.

**Context:**
- 0.4.0 hasn't shipped. Devi's 2026-10-28 notes say everything in Unreleased is merged and tested on Linux and macOS. The open question is #57, a Windows-only crash, and Priya owns the release decision.
- Maya's billing and support analytics teams are waiting on the #42 fix. Maya said they'll check for the truncated-row message in their scripts, so keep that wording stable.
- Devi's draft agent rules (`docs/agent-rules-draft.md`) say not to slow `read_row()` down, so keep that in mind for any fix.
