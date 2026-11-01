# splitlane 0.4.0

This release fixes how splitlane handles quoted fields that contain line breaks (#42). It also renames the output files, which **breaks scripts that look for the old names**. Read "Before you upgrade" first.

## Before you upgrade

### Output files have new names

Chunks used to be named `chunk_1.csv`, `chunk_2.csv`, and so on. They are now `part-0001.csv`, `part-0002.csv`, and so on.

- Update any script, glob or pipeline step that matches `chunk_*.csv`.
- The zero-padded numbers sort correctly by name, so `part-0010.csv` now comes after `part-0009.csv`.
- splitlane does not delete old files. If you write into an `--out` directory left over from 0.3.1, the old `chunk_*.csv` files stay next to the new `part-*.csv` files. Start with an empty output directory, or clear out the old files.

### Rows with line breaks inside quotes stay whole

A quoted field that contains a line break, like a multi-line `notes` column, now stays in one row, as RFC 4180 specifies:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

0.3.1 read this as three data rows, two of them broken. 0.4.0 reads it as two. If your files contain such fields:

- Row counts per chunk and the number of chunks can change.
- Chunks now contain quoted line breaks. Make sure the tool that reads them handles quoted fields properly. Most CSV parsers and spreadsheets do.

## What's new

### Warning for truncated rows

A row longer than `--max-row-bytes` (default 65536) is cut at that limit, and splitlane continues from the next line. At the end of the run, splitlane now tells you how many rows were cut:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

**The exit status is still 0 when rows are truncated.** If you can't afford to lose data, check stderr for this warning in your scripts.

This limit also protects you from malformed input. A stray, unmatched `"` used to be able to turn the rest of the file into one field. Now the damage stops at `--max-row-bytes`. The lines after the stray quote, up to the limit, end up in a single truncated row, and they are counted in the warning.

Library users: `read_row()` now returns a `(row, truncated)` pair, so you can detect truncated rows yourself.

### Clear errors and exit codes

- **`--rows 0`** (or any negative value) used to loop forever. It now exits with status **2** and the message `--rows must be at least 1`.
- **Input that can't be decoded** now exits with status **3** and names the encoding that failed. For example, `cannot decode export.csv as utf-8: ...`. Try again with the right encoding, such as `--encoding latin-1` for ISO-8859 files.
  - Any chunks written before the error stay in the output directory, and the last one may be incomplete. Delete them before you run again.

## Known issues

- **Windows: overwriting a chunk that's open in another program fails (#57).** If a chunk from an earlier run is open in Excel, for example, splitlane stops with a `PermissionError` when it tries to overwrite that file. The chunks before it have already been replaced, and the error doesn't say which ones, so the directory ends up with a mix of new and old chunks. Workaround: close the chunk files before you run splitlane, or write to a new, empty `--out` directory.
- **Recovery after a truncated row can land inside a quoted field.** After cutting a row, splitlane continues at the next line break, even if that break is inside a quoted multi-line field. In rare cases, the rows right after a truncated row can be split wrongly. If the truncation warning appears, check the rows near the damaged one.

## Full changelog

- Fix: `--rows 0` now exits with status 2 and a message, instead of looping.
- Fix: a quoted field containing a newline stays in one row (#42).
- Fix: an unterminated quote no longer swallows the rest of the file. The row stops at `--max-row-bytes` and counts as truncated (#42).
- Change: output files are named `part-0001.csv`, `part-0002.csv`, … instead of `chunk_1.csv`, `chunk_2.csv`, ….
- Report the number of truncated rows at the end of a run.
- Exit with status 3 when the input cannot be decoded.
