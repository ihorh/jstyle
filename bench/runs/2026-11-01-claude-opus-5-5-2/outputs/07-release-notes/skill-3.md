# splitlane 0.4.0

This release keeps a quoted field that contains line breaks in one row. It also reports truncated rows and gives clear errors for bad input. The output files have new names, which breaks any script that looks for the old names, so read "Before you upgrade" first.

## Before you upgrade

**Chunk files have new names.** 0.3.1 wrote `chunk_1.csv`, `chunk_2.csv`, and so on. 0.4.0 writes `part-0001.csv`, `part-0002.csv`, and so on. Update any script that finds chunks by name or by a pattern such as `chunk_*.csv`.

splitlane never deletes anything in the output directory. If you reuse a directory from a 0.3.1 run, the old `chunk_*.csv` files stay next to the new `part-*.csv` files. The same goes for any rerun: if the new run writes fewer chunks than the last one did, the extra `part-*.csv` files from the last run are left behind. Empty the directory first, or point `--out` at a new one.

**Your chunks can change if your input has multi-line fields.** See the next section.

## What's changed

### Line breaks inside quotes stay in their row (#42)

A field in double quotes may contain a line break, as RFC 4180 allows. Exports with a free-text column, such as notes, often have them. 0.3.1 ended a row at every line break, so one record became two broken rows with the wrong number of columns. 0.4.0 keeps the line break inside the field, and the record stays one row.

For files with such fields, the chunks differ from what 0.3.1 wrote. Every record is whole, and `--rows` counts records rather than lines. As before, the count doesn't include the header row.

### A stray quote damages one row, not the rest of the file (#42)

Tracking quotes has a risk. One unmatched `"` would make everything after it look like a single quoted field. splitlane limits the damage with `--max-row-bytes` (added in 0.3.0, default 65536). When a row grows past that limit, splitlane cuts the row there and writes the shortened row to the chunk. It counts the row as truncated and carries on reading from the next line break.

- The truncated row loses everything past the limit. If your input has real rows longer than 65536 bytes, raise `--max-row-bytes`.
- splitlane carries on from the next line break even when that line break is inside a quoted field. In rare cases, the row after a truncated one can also be split in the wrong place.

### Truncated rows are reported

splitlane truncated rows longer than `--max-row-bytes` in 0.3.x too, but it did so silently. Now, at the end of a run, it prints on stderr how many rows it truncated:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

The byte count in the warning is your `--max-row-bytes` value. The warning doesn't say which rows were truncated, and the exit status is still 0. If your pipeline must not accept shortened rows, check stderr for this warning.

### Clear errors for bad input

- **`--rows` below 1.** splitlane exits with status 2 and prints `splitlane: --rows must be at least 1`. In 0.3.1, `--rows 0` made it loop forever.
- **Input that doesn't match `--encoding`.** The default encoding is `utf-8`. When the input can't be decoded, splitlane exits with status 3 and prints a message that names the file and the encoding, where 0.3.1 crashed with a Python traceback. The chunks written before the bad byte stay in the output directory, and the last one is only partly written, so don't treat them as a complete result. If your file isn't UTF-8, pass its encoding, for example `--encoding latin-1` for an ISO-8859-1 export.

## Known issue: Windows, chunk files open in Excel (#57)

On Windows, if a chunk file from an earlier run is open in Excel, splitlane crashes with `PermissionError` when it tries to overwrite that file. By then it has already overwritten the chunks before that one, and the error doesn't say which file failed. The output directory ends up with a mix of new and old chunks. Close the chunk files before you run splitlane, or write to a new, empty directory.
