Hi Sam, welcome aboard. You're picking up tomasz's open follow-up on #42. You don't need to read the whole thread first; here's what you need.

**The original bug.** Maya reported it for the billing and support analytics teams. Their CRM exports have a `notes` column, and some notes contain line breaks inside quotes. splitlane ended each row at the first `\n`, so one customer record came out as two broken rows and their importer rejected the chunk. In 0.1 devi deliberately ignored quotes, because tracking them means one stray `"` can make the reader treat the rest of the file as a single field.

**What was decided and merged (devi, 2026-10-02):**
- `read_row()` now tracks quotes, so a newline inside quotes stays in the field, as RFC 4180 specifies (`src/splitlane/split.py:18-21`).
- To keep a stray quote from swallowing the file, a row that grows past `--max-row-bytes` (default 64 KiB) is cut off there. It's flagged as truncated and the reader skips to the next newline (`split.py:23-29`). A stray quote then damages one row instead of the whole file.
- Truncation is never silent. The CLI prints a warning with the count at the end of a run (`cli.py:34-36`), and `read_row()` returns a flag for library callers. Maya's scripts check for that warning, so please don't change its wording without telling her.

**Your task, tomasz's follow-up (2026-10-03).** After a truncation, the skip goes to the next `\n` even if that newline is inside quotes (`split.py:24-28`). In a bad case the reader can resync in the middle of a real multi-line field. tomasz called this probably rare and not blocking. One thing I noticed from reading the code that's not in the thread, so please verify it: the next `read_row()` call starts with `in_quotes = False`. If it resyncs mid-field, that field's closing `"` would open a new quote, which could cause a second truncation. So the damage may spread past one row. A test that reproduces this would be a good first step. The repo doesn't have tests for this path yet.

**Release context.** The #42 fix is merged for 0.4.0 but hasn't shipped. 0.4.0 is held up by #57, a Windows-only crash when a chunk file is open in Excel. Priya is deciding whether to ship now with a known-issue note or wait for the fix (see `notes/release-status.md`). Billing and support analytics are waiting on #42 and both run on Linux. Since your follow-up isn't blocking, it shouldn't hold up 0.4.0. It can go in a later release unless the cascade turns out to be worse than tomasz expected.

People: devi wrote the fix, tomasz raised the follow-up, and maya represents the affected teams.
