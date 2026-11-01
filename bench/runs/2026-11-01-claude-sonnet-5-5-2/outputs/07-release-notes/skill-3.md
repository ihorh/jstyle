# splitlane 0.4.0

This release fixes how splitlane handles multi-line quoted fields (#42). It also renames the output files, which can break scripts that read them. Read **Upgrading from 0.3.1** before you run it on existing pipelines.

## Upgrading from 0.3.1

- **Output files are renamed.** Chunks are now named `part-0001.csv`, `part-0002.csv`, and so on. 0.3.1 wrote `chunk_1.csv`, `chunk_2.csv`. Update any script or glob that expects the old names. If you reuse an output directory, delete the old `chunk_*.csv` files first. 0.4.0 does not overwrite or remove them, so the directory would hold both sets.
- **Truncated rows now produce a warning.** The warning goes to stderr at the end of a run: `splitlane: warning: N row(s) longer than <limit> bytes were truncated`. The exit status stays 0, so a script that needs to catch truncation has to check for this message.
- **Undecodable input now exits with status 3.** The error message names the file and the encoding it tried. Pass `--encoding` with the right one, for example `--encoding latin-1` for an ISO-8859 file. Chunks written before the bad byte are left in the output directory, so clear it before you re-run.
- **`--rows 0` now exits with status 2.** It prints `--rows must be at least 1` instead of looping. Negative values get the same error.

## Fixed

- **A quoted field that contains a newline now stays in one row (#42).** Before, splitlane treated every line break as the end of a row. A CRM-style `notes` column with line breaks was split into two rows, and the second row had the wrong number of columns. Splitlane now follows RFC 4180 and keeps newlines that sit inside quotes.
- **An unterminated quote no longer swallows the rest of the file.** A stray `"` could make the reader treat everything after it as one field. Now the row stops at `--max-row-bytes` (default 65536) and is counted as truncated. Splitlane then skips to the next newline and carries on, so one damaged row costs you one row. Multi-line fields stay far below that limit in normal data. If your notes can be longer than 64 KB, raise `--max-row-bytes`.

## Known limitations

- After a row is truncated, splitlane resumes at the next newline, even if that newline is inside quotes. In rare cases it can resume in the middle of a real multi-line field.
- **Windows:** if a chunk file from an earlier run is open in Excel, splitlane fails with `PermissionError` when it tries to overwrite that file (#57). The error does not say which file, and chunks written before it are already replaced. Close your spreadsheet and clear the output directory before you re-run.

## Library users

`read_row()` returns a flag that tells you whether the row was truncated. Column counting has moved into `split.py` (`count_columns`).
