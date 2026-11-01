# splitlane 0.4.0

This release fixes how quoted fields with line breaks are handled, and it renames the output files. If you're upgrading from 0.3.1, read the first two sections before you run it on a real pipeline.

## Changes that may break your setup

**Output files have new names.** Chunks were `chunk_1.csv`, `chunk_2.csv`, and so on. They are now zero-padded: `part-0001.csv`, `part-0002.csv`. Update any script or pipeline that looks for the old names. A glob such as `chunk_*.csv` will no longer match.

**Undecodable input now exits with status 3.** If the input can't be decoded with the chosen `--encoding`, splitlane prints `cannot decode <file> as <encoding>` and exits with status 3. If the file isn't UTF-8, pass the right `--encoding`. Chunks written before the bad byte are not removed, so a failed run can leave a partial `part-0001.csv` in the output directory.

## Fixes

- **Quoted fields with line breaks stay in one row (#42).** A line break inside a quoted field no longer ends the row, so a multi-line note in a CRM export stays in a single row. Before, it became two rows, and the second had the wrong number of columns.
- **A stray quote no longer swallows the rest of the file (#42).** An unmatched `"` used to make the reader treat everything after it as one field. Now the row stops at `--max-row-bytes`, is counted as truncated, and reading resumes at the next line. One bad quote damages one row.
- **`--rows 0` no longer loops forever.** It now prints `--rows must be at least 1` and exits with status 2.

## New

- **Truncated rows are reported.** At the end of a run, splitlane prints a warning to stderr with the number of rows that went over `--max-row-bytes` and were cut. A truncated row is shortened, and your importer may not notice. If that matters to you, check for this warning in your scripts.

## Known issues

- **Resync after a truncated row can land inside a quoted field.** The reader resumes at the next line break even if that break is inside quotes. In that rare case, one more row can come out damaged.
- **Windows: overwriting an open chunk crashes the run (#57).** If a chunk from an earlier run is open in Excel, splitlane stops with a `PermissionError`. Chunks written before that point stay on disk, and the error doesn't say which chunk failed. You end up with a mix of new and old files. Close the files, or write to an empty output directory.
