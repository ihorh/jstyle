Hi Sam, welcome. Here's where things stand on the #42 follow-up you're taking over from tomasz.

**Background.** #42 was a bug where a quoted CSV field with a line break in it (common in CRM `notes` columns) got split into two broken rows. Two teams reported it, billing and support analytics. In 0.1, devi had made the reader ignore quotes on purpose. The worry was that one stray `"` would make it read the rest of the file as a single field. Quote tracking brought that problem back during testing: one stray quote in a 400k-row file turned everything after it into one huge row. The fix they agreed on keeps quote tracking but caps it with the existing `--max-row-bytes`:

- A real multi-line note stays well under the limit.
- If a row goes over the limit, it's cut there and counted as truncated, and the reader skips ahead to the next newline. One stray quote costs one row instead of the rest of the file.
- Truncation is reported, not silent. The CLI prints how many rows were truncated at the end of a run, and `read_row()` returns a flag. Maya's team checks for that CLI message in their scripts, so don't change how it's worded without telling them.

devi merged this on 2026-10-02 and closed the issue. It's in the Unreleased (0.4.0) section of `CHANGELOG.md`.

**Your follow-up.** After a row is truncated, the skip in `src/splitlane/split.py:24-29` goes to the next `\n` without tracking quotes. If that newline is inside a real multi-line field, the reader picks up again in the middle of that field. From there its quote state is flipped, so following rows can be split wrong or run into the byte limit again. Each failure is still capped at `--max-row-bytes`, so the file never gets swallowed. But one stray quote can damage more than the one row we promised. tomasz thinks it's rare and said it's not blocking. Nobody has measured how often it happens or prototyped a fix, so the approach is up to you. A good first step is a test case that triggers it: a stray quote, followed within the byte limit by a real multi-line quoted field.

**Release context.** This doesn't block 0.4.0. What's holding the release is #57, a Windows-only crash when a chunk file is open in Excel. Priya is deciding whether to ship now or wait. Billing and support analytics are waiting for the #42 fix, so anything you change in `read_row()` will probably land after 0.4.0, not in it.

The full thread is in `issues/42-quoting.md`, and devi's release notes are in `notes/release-status.md`. devi wrote the reader, so ask them about the code.
