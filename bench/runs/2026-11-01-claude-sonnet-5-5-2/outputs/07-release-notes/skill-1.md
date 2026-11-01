# splitlane 0.4.0

This release fixes quoted fields that contain line breaks (#42). It also renames the output files, which affects any script that reads them by name.

## Changes that may break your scripts

- **Output files are renamed.** Chunks are now `part-0001.csv`, `part-0002.csv`, and so on. They were `chunk_1.csv`, `chunk_2.csv`. Update any script or pipeline that looks for the old names. If you write to a directory that still holds chunks from 0.3.1, the old `chunk_*.csv` files stay there next to the new ones. Clear the directory first.
- **Exit status 3 means the input could not be decoded.** Use `--encoding` to name the right encoding. splitlane reads the input as it writes, so chunks written before the bad byte stay in the output directory, and the last one is incomplete. Delete them before you run again.
- **`--rows 0` now exits with status 2** and prints an error. In 0.3.1 it looped.

## Quoted line breaks stay in one row

Before, splitlane ended a row at every line break, even inside a quoted field. A CRM export with multi-line notes came out as broken rows with the wrong number of columns. Now a line break inside quotes stays in its row, as RFC 4180 specifies.

An unterminated quote could make splitlane read the rest of the file as one field. To prevent that, a row that grows past `--max-row-bytes` (default 65536) is cut at that limit. splitlane then skips to the next line break and carries on. A stray quote now damages one row instead of the rest of the file.

## Truncated rows are reported

A cut row is shortened, so its data is lost. At the end of a run splitlane prints a warning to stderr:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

The exit status stays 0. If a downstream step must not receive shortened rows, have your script check stderr for this warning.

Known limitation: after a cut, splitlane resumes at the next line break even if that break is inside quotes. In a bad case it may resume in the middle of a real multi-line field. We expect this to be rare.

## Known issue on Windows (#57)

If a chunk from an earlier run is open in Excel, splitlane stops with a `PermissionError` when it tries to overwrite that file. The chunks written before it are already new, and the error doesn't say which file was locked. The result is a mix of new and old chunks. Close the files, or write to an empty directory, before you run splitlane. We have not fixed this yet.

## Other

- Column counting moved into `split.py`. This is an internal change.
