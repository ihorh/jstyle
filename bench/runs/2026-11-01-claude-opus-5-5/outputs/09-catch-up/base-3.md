Hi Sam, here's what you need to know about #42 and the follow-up you're taking over from tomasz.

**The original bug.** Maya reported that splitlane split CRM exports wrongly when a quoted `notes` field contained a line break. One customer record turned into two broken rows, and their importer rejected the whole chunk. In 0.1, devi had made `read_row()` ignore quotes on purpose, so that one stray `"` couldn't make the reader treat the rest of the file as a single field.

**What got merged (2026-10-02, ships in 0.4.0).** `read_row()` in `src/splitlane/split.py` now tracks quotes, so a newline inside quotes stays part of the field. To stop a stray quote from swallowing the file, the row is capped at `--max-row-bytes` (default 64 KiB). If a row goes over that limit, it's cut off, flagged as truncated, and the reader skips ahead to the next newline. The CLI prints how many rows were truncated at the end of a run, and library callers get a flag back from `read_row()`. Maya's teams (billing and support analytics) will check their scripts for that CLI message.

**Your follow-up.** The skip after truncation (`split.py:24-28`) stops at the first `\n` it finds, even if that newline is inside quotes. After that, the next `read_row()` call starts with `in_quotes = False`. So if the skip lands in the middle of a real multi-line field, the rest of that field gets read as separate rows. Its closing `"` then flips the reader into "inside quotes" when it isn't, and that can cause another truncation further on. Tomasz called it "probably rare, not blocking." No one has reproduced it or opened a separate issue for it yet.

**Things to keep in mind:**
- Devi is opposed to any fix that brings back the old risk of one bad quote swallowing the file. Any change has to keep the damage limited.
- An earlier idea to detect a broken quote by counting lines was rejected, because real notes fields can contain many lines.
- 0.4.0 isn't released yet. It's waiting on #57, a Windows crash, and Priya is deciding whether to ship anyway. This follow-up isn't part of that decision, so don't put it on the 0.4.0 critical path.

A good first step would be a test file that triggers the bad resync, so we can see how bad it really is. The full thread is in `issues/42-quoting.md`.
