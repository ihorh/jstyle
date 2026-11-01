# splitlane 0.4.0

## Breaking change

**Output files are named differently.** Chunks are now written as `part-0001.csv`, `part-0002.csv`, and so on. In 0.3.1 they were `chunk_1.csv`, `chunk_2.csv`, and so on. The new names are zero-padded to four digits, so they sort correctly. Update any script, glob, or pipeline that looks for `chunk_*.csv`.

## Fixes

- **Quoted fields with line breaks stay in one row (#42).** A quoted field that contains a newline, such as a multi-line `notes` column, is no longer split into two broken rows. Chunks from this kind of export now have the right number of columns.
- **An unterminated quote no longer swallows the rest of the file.** If a row grows past `--max-row-bytes` (default 65536), splitlane cuts it there, counts it as truncated, and carries on from the next newline. A stray `"` now damages one row instead of the rest of the file.
- **`--rows 0` no longer loops forever.** Any `--rows` value below 1 now prints an error and exits with status 2.

## New

- **Truncated rows are reported.** At the end of a run, the CLI prints a warning on stderr with the number of rows that were cut at `--max-row-bytes`. If you run splitlane in scripts, check for this message. A truncated row is shortened, so a downstream importer may not notice. Library callers get a truncation flag from `read_row()`.
- **Undecodable input has its own exit status.** If the input can't be decoded with the chosen `--encoding`, splitlane prints an error and exits with status 3.

## Known limitation

After a row is truncated, splitlane resumes at the next newline, even if that newline is inside a quoted field. In rare cases it can resume in the middle of a real multi-line field.

## Upgrading from 0.3.1

1. Update anything that expects `chunk_N.csv` to expect `part-NNNN.csv`.
2. If you rely on exit codes, handle the new statuses: 2 for invalid `--rows` and 3 for a decoding error.
3. Check for the truncation warning in your logs, or raise `--max-row-bytes` if you have legitimately large rows.
