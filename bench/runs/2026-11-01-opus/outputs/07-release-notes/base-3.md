# splitlane 0.4.0

This release changes the names of the output files, so scripts that look for chunk files by name will need updating. It also fixes how rows with line breaks inside quoted fields are handled (#42), and adds clearer errors and exit codes.

## Breaking change: output file names

Chunk files now use zero-padded names:

| 0.3.1           | 0.4.0             |
|-----------------|-------------------|
| `chunk_1.csv`   | `part-0001.csv`   |
| `chunk_2.csv`   | `part-0002.csv`   |
| `chunk_10.csv`  | `part-0010.csv`   |

Before you upgrade:

- **Update any script, glob or pipeline step that expects `chunk_*.csv`.** Use `part-*.csv` instead. With the padding, the files now sort in the right order with a plain `ls` or `sort`.
- **Clear out old output directories.** splitlane doesn't delete anything in `--out`. If you reuse a directory from a 0.3.1 run, the old `chunk_*.csv` files will still be there next to the new `part-*.csv` files.

## Fixed: line breaks inside quoted fields (#42)

A quoted field that contains a line break now stays in a single row, as RFC 4180 requires. For example:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

0.3.1 split this into three broken rows. 0.4.0 correctly reads it as two rows. If your exports have multi-line text fields, such as notes or addresses, your chunks will now have the right column counts. Rows per chunk will no longer match lines per file, and each chunk may have fewer lines than before.

## Changed: rows that don't fit in `--max-row-bytes`

Tracking quotes brings a risk: one stray `"` could make the rest of the file look like a single field. To limit the damage, any row that grows past `--max-row-bytes` (default 65536) is cut off at that limit:

- The part of the row up to the limit is written to the chunk. Everything after it, up to the next line break, is discarded.
- Reading continues with the next line, so the rest of the file is processed as usual.
- At the end of the run, splitlane prints how many rows were cut off to stderr:

  ```
  splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
  ```

**The exit status is still 0 when rows are truncated.** If your pipeline can't accept incomplete rows, check stderr for this warning. A truncated row will usually have too few columns or an unclosed quote.

If you have legitimately long rows, raise `--max-row-bytes`.

Known limitation: after cutting off a row, splitlane resumes at the next line break, even if that line break is inside a quoted field. If the bad row is followed by a real multi-line field, one or two more rows may come out malformed before reading gets back in step.

## New: clearer errors and exit codes

| Exit status | Meaning |
|-------------|---------|
| 0 | Success (check stderr for truncation warnings, see above) |
| 2 | Invalid arguments. For example, `--rows 0` or a negative `--rows` used to hang. It now exits right away with `splitlane: --rows must be at least 1`. |
| 3 | The input file couldn't be decoded with the given `--encoding`. |

On a decoding error, splitlane names the file and encoding along with the problem:

```
splitlane: cannot decode exports/customers.csv as utf-8: 'utf-8' codec can't decode byte 0xe9 in position 4183: invalid continuation byte
```

This usually means the file isn't UTF-8. Exports from older systems are often Latin-1 or Windows-1252. Run again with, for example, `--encoding latin-1`.

**Chunks written before the error are left in the output directory.** If you get exit status 3, delete the partial output before running again.

## Known issue: Windows, chunk files open in another program (#57)

On Windows, if a chunk file from an earlier run is open in another program (Excel, for example), splitlane crashes with a `PermissionError` when it tries to overwrite that file. The chunks before it have already been rewritten, so the output directory ends up with a mix of new and old chunks, and the error message doesn't say which file failed.

Until this is fixed, close any open chunk files before running splitlane on Windows, or write to a new, empty `--out` directory each time.

## Upgrade checklist

1. Change any references from `chunk_*.csv` to `part-*.csv`.
2. Empty or replace output directories that are left over from 0.3.1.
3. If you need complete rows, check stderr for `row(s) ... were truncated`.
4. Treat exit status 2 and 3 as failures, and clean up partial output after a status 3.
5. On Windows, close open chunk files before running, or use a fresh `--out` directory.
