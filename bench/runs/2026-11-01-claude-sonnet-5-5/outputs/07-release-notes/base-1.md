# splitlane 0.4.0

## Before you upgrade

**Output files are renamed.** Chunks are now named `part-0001.csv`, `part-0002.csv` and so on. In 0.3.1 they were `chunk_1.csv`, `chunk_2.csv`. The numbers are zero-padded to four digits, so the files sort correctly. If a script or glob expects `chunk_*.csv`, update it to `part-*.csv`.

**There are new exit statuses.**
- `--rows 0` (or any value below 1) now exits with status 2 and prints an error. In 0.3.1 it looped forever.
- Input that can't be decoded with the chosen `--encoding` now exits with status 3 and a message. Check your wrapper scripts if they treat every non-zero status the same way.

## Fixes

- **Quoted fields that contain newlines stay in one row (#42).** In 0.3.1 a line break inside a quoted field, such as a multi-line `notes` column, split one record into two broken rows. Those rows have the right shape now, as RFC 4180 describes.
- **A stray quote no longer swallows the rest of the file.** An unterminated quote now stops at `--max-row-bytes`. That row is cut there and counted as truncated, and reading picks up again at the next line. A stray quote damages one row instead of the whole file.

## New

- **Truncated rows are reported at the end of a run.** If any row was cut at `--max-row-bytes`, splitlane prints a warning to stderr with the count. A truncated row is shortened without any other signal, so a downstream importer won't notice. If you need to catch this, check for the warning in your scripts.
- Library users get a truncation flag from `read_row()`.

## Known issues

- **Windows: overwriting chunks that are open in Excel (#57).** If a chunk file from an earlier run is open in Excel, splitlane stops with a `PermissionError` when it tries to overwrite that file. Chunks written before that point stay on disk, and the error doesn't say which file caused it. You end up with a mix of new and old chunks. Close the files in Excel or write to an empty output directory.
- After a truncation, reading resumes at the next newline even if that newline is inside quotes. In rare cases this can resume in the middle of a real multi-line field.
