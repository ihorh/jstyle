# splitlane 0.4.0

splitlane now keeps a quoted field that contains a line break in a single row (#42). Exports with multi-line fields, such as CRM notes, now split correctly. This release also renames the output files, so check any script that reads them before you upgrade.

## Before you upgrade

**The output files have new names.** 0.3.1 wrote `chunk_1.csv`, `chunk_2.csv`, and so on. 0.4.0 writes `part-0001.csv`, `part-0002.csv`, and so on. Update any script, glob, or pipeline step that looks for `chunk_*.csv`.

The zero padding makes the files sort in order by name, up to `part-9999.csv`. A run that writes more than 9,999 chunks produces five-digit names, and those don't sort correctly by name next to the four-digit ones.

**Clear out old output directories.** 0.4.0 doesn't delete or overwrite `chunk_*.csv` files. If you write into a directory that 0.3.1 used, the old chunks stay next to the new ones. Empty the directory first, or pass a new `--out`.

## Fixes

- **Line breaks inside quoted fields.** A quoted field that contains a line break now stays in one row, as RFC 4180 specifies. In 0.3.1, splitlane ended the row at the line break. That turned one record into two broken rows with the wrong number of columns (#42).

  ```
  id,name,notes
  7,Ana,"called twice
  asked for refund"
  8,Bo,ok
  ```

  0.4.0 reads two data rows from this input. 0.3.1 read three.

- **`--rows 0` no longer hangs.** A `--rows` value below 1 now stops the run with exit status 2 and this message:

  ```
  splitlane: --rows must be at least 1
  ```

  In 0.3.1, `--rows 0` looped forever.

## Changes

- **Unclosed quotes are contained.** splitlane now tracks quotes, so a stray `"` that is never closed makes it read on past the end of the line. 0.4.0 caps the damage with `--max-row-bytes`, which defaults to 65536. When a row grows past that limit, splitlane keeps the first 65536 bytes, skips ahead to the next line break, and counts the row as truncated. Every row that the stray quote ran into ends up inside that one truncated row, so those rows are lost as separate records. The rest of the file splits normally.

- **Truncated rows are reported.** In 0.3.1, splitlane truncated rows longer than `--max-row-bytes` without telling you. Now, if any rows were truncated, the run ends with a warning on stderr:

  ```
  splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
  ```

  The exit status is still 0 when this happens. If your pipeline must not accept truncated rows, check stderr for this line.

- **Encoding errors have their own exit status.** If splitlane can't decode the input with `--encoding`, it now exits with status 3 and a one-line message, instead of a Python traceback:

  ```
  splitlane: cannot decode exports/customers.csv as utf-8: 'utf-8' codec can't decode byte 0xe9 in position 4183: invalid continuation byte
  ```

  Chunks written before the error stay in the output directory, and the last one is cut off partway. Delete them, then run again with the right encoding, for example `--encoding latin-1` for an ISO-8859 export.

### Exit statuses

| Status | Meaning |
|---|---|
| 0 | Success, including runs that truncated rows (see the warning on stderr) |
| 2 | Invalid arguments, including `--rows` below 1 |
| 3 | The input couldn't be decoded with `--encoding` |

## Known issues

- **Windows: chunks open in Excel (#57).** If a chunk from an earlier run is open in Excel, splitlane crashes with `PermissionError` when it tries to overwrite that chunk. The chunks before it have already been overwritten, and the error doesn't say which chunk failed. The output directory is left with a mix of new and old chunks. Until this is fixed, close the chunks in Excel before you run splitlane, or write each run to a new `--out` directory.

- **Recovery after a truncated row can land inside a quoted field.** After it truncates a row, splitlane skips ahead to the next line break, even if that line break is inside a quoted field. In that case, the rows right after the truncated row can be split incorrectly. This needs an unclosed quote near a legitimate multi-line field, so we expect it to be rare.
