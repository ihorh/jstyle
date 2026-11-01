# splitlane 0.4.0

## Upgrade notes

- **Output files are renamed.** Chunks are now named `part-0001.csv`, `part-0002.csv`, and so on. In 0.3.1 they were `chunk_1.csv`, `chunk_2.csv`. If your scripts, globs, or downstream jobs look for `chunk_*.csv`, update them. Because the numbers are zero-padded, the files now sort correctly.
- **New exit codes.** `--rows 0` (or any value below 1) now exits with status 2 and an error message. In 0.3.1 it looped. Input that cannot be decoded with the chosen `--encoding` now exits with status 3 and a message. If you wrap splitlane in scripts, handle these.

## Fixes

- **Quoted fields with line breaks stay in one row (#42).** A field like `"called twice⏎asked for refund"` is no longer split into two broken rows. Chunks from exports with multi-line notes columns now have the right number of columns.
- **An unterminated quote no longer swallows the rest of the file (#42).** A row that grows past `--max-row-bytes` is cut at that limit and counted as truncated. Reading resumes at the next line, so one bad quote damages one row instead of the rest of the file.

## New

- **Truncated-row report.** At the end of a run, the CLI prints a warning on stderr if any rows were truncated:
  `splitlane: warning: N row(s) longer than <limit> bytes were truncated`
  A truncated row is shortened, so check for this message if your downstream importer wouldn't notice. Library users get a flag from `read_row()`.

## Known limitation

- After a truncated row, splitlane skips to the next newline, even if that newline is inside quotes. In rare cases it can resume in the middle of a real multi-line field. Only rows around a malformed quote are affected.
