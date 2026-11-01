Hi Sam, welcome. Here's where #42 stands and what tomasz's follow-up is about.

**The original bug.** Maya reported it. Billing and support analytics get CRM exports with a `notes` column, and some notes contain line breaks inside properly quoted fields. splitlane cut the row at every `\n`, so one record came out as two broken rows and their importer rejected the whole chunk.

**Why it wasn't simply fixed.** In 0.1, devi made `read_row()` ignore quotes on purpose. If the reader tracks quotes, one stray `"` can make it treat the rest of the file as a single field. devi tested a first fix and saw exactly that: one bad quote in row 12 of a 400k-row file produced a chunk with a header and one enormous row.

**What was merged (ships in 0.4.0).**
- `read_row()` now tracks quotes, so a newline inside quotes stays in the field.
- The existing `--max-row-bytes` limit (default 64 KiB) caps how far a row can grow. A real note stays well under it. A stray quote hits it, the row is cut there and marked truncated, and the reader skips to the next newline to recover. Instead of losing the rest of the file, you lose one row.
- The cut isn't silent. The CLI prints how many rows were truncated at the end of a run, and `read_row()` returns a flag for library callers. Maya's team will check for that message in their scripts.

**Your follow-up.** tomasz raised it after the merge and called it "probably rare, not blocking." After a truncation, the skip goes to the next newline *even if that newline is inside quotes* (`src/splitlane/split.py:24-28`). If a real multi-line field comes soon after the bad quote, the reader can restart in the middle of it. One more thing from reading the code, which I haven't tested: the reader restarts with `in_quotes = False`. If it lands mid-field, that field's closing quote will look like an opening quote, so the error could carry into the next row or cause another truncation instead of staying at one damaged row. Checking that would be a good first step. I didn't find any tests in the repo, so a test file with a stray quote followed by a real multi-line note is probably the place to start.

**Release context.** 0.4.0 hasn't shipped yet. It's held up by #57, a Windows-only crash when a chunk file is open in Excel. Priya is deciding whether to ship now with a known-issue note or wait for that fix. Billing and support analytics run on Linux and are waiting on the #42 fix, so don't let this follow-up hold up the release. It can go in 0.4.x.

People: maya is the reporter, devi wrote the fix and knows `read_row()` best, and tomasz raised the follow-up.
