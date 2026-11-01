# splitlane 0.4.0

This release fixes how splitlane handles quoted fields that contain line breaks (#42). It also renames the output files, which **will break scripts that look for the old names**. Read "Breaking changes" before you upgrade from 0.3.1.

## Breaking changes

### Output files have new names

Chunks used to be named `chunk_1.csv`, `chunk_2.csv`, and so on. They are now zero-padded:

| 0.3.1         | 0.4.0           |
|---------------|-----------------|
| `chunk_1.csv` | `part-0001.csv` |
| `chunk_2.csv` | `part-0002.csv` |
| `chunk_12.csv`| `part-0012.csv` |

The new names sort correctly in file listings and shell globs.

**What to do:**

- Update any scripts, globs or pipeline steps that match `chunk_*.csv`. Use `part-*.csv` instead.
- splitlane does not delete old files. If you run 0.4.0 into an `--out` directory that still holds `chunk_*.csv` files from an earlier run, both sets will be there side by side. Clear the directory first, or use a new one.

### Row boundaries follow CSV quoting

A line break inside a quoted field now stays part of that field, as RFC 4180 specifies. In 0.3.1 every line break ended a row, so one record with a multi-line field became two or more broken rows.

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

0.3.1 wrote three data rows for this input. 0.4.0 writes two.

If your data has multi-line fields, expect the following:

- Row counts per chunk change, because `--rows` now counts real records, not lines.
- The length limit applies to the whole record. `--max-row-bytes` (default 65536) now counts every line of a multi-line field together. Legitimate rows with very long notes may now go over the limit. If you get truncation warnings on good data, raise `--max-row-bytes`.

## Fixes

- **Multi-line quoted fields stay in one row** (#42).
- **A stray quote no longer eats the rest of the file** (#42). If a quote is never closed, splitlane stops the row at `--max-row-bytes`, counts it as truncated, and carries on from the next line. Only one row is damaged.
- **`--rows 0` no longer loops forever.** A `--rows` value below 1 now exits right away with status 2 and the message `splitlane: --rows must be at least 1`.

## New behavior

### Truncation warning

When a run truncates rows, splitlane now ends with a line on stderr like this:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

A truncated row is cut at the limit and the rest of it is thrown away. **The exit status is still 0 when rows are truncated.** If your pipeline needs to catch data loss, check stderr for `splitlane: warning:`.

Library users: `read_row()` returns a `(row, was_truncated)` pair, and `split_file()` returns `(written_files, truncated_count)`.

### Exit status 3 for encoding errors

If the input can't be decoded with `--encoding` (default `utf-8`), splitlane prints an error and exits with status 3:

```
splitlane: cannot decode exports/customers.csv as utf-8: 'utf-8' codec can't decode byte 0xe9 in position 4183: invalid continuation byte
```

**Chunks written before the error stay on disk.** After a failure, the output directory can contain a partial `part-0001.csv` (and possibly more files). Don't use output from a run that exited with status 3. Delete it and run again with the right encoding, for example `--encoding latin-1` for ISO-8859-1 files.

## Exit status summary

| Status | Meaning |
|--------|---------|
| 0 | Success (check stderr for truncation warnings) |
| 2 | Invalid arguments, e.g. `--rows` below 1 |
| 3 | Input could not be decoded with `--encoding` |

## Known issues

- **Windows: a crash can leave a mix of old and new chunks (#57).** If a chunk file from an earlier run is open in another program, such as Excel, splitlane crashes with `PermissionError` when it tries to overwrite that file. The chunks before it have already been replaced and the ones after it have not, and the error doesn't say which file failed. Until this is fixed, close any open chunk files before running, or write each run to a new, empty `--out` directory.
- **Recovery after truncation can land inside a real field.** After truncating a row, splitlane picks up again at the next line break, even if that line break is inside a quoted field. In rare cases, a stray quote just before a real multi-line field can damage the rows around it. The truncation warning will still report it.
