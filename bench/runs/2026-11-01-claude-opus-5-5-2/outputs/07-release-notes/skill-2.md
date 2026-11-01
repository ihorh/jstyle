# splitlane 0.4.0

This release fixes how splitlane handles quoted fields that contain line breaks. It also renames the output files, which may break scripts written for 0.3.1. Read "Before you upgrade" first.

## Before you upgrade

### Output files have new names

Chunks used to be named `chunk_1.csv`, `chunk_2.csv`, and so on. They are now `part-0001.csv`, `part-0002.csv`, and so on.

- **Update any script or pipeline step that looks for `chunk_*.csv`** so that it looks for `part-*.csv`.
- **Clear the output directory before the first run.** splitlane 0.4.0 doesn't delete or overwrite the old `chunk_*.csv` files. If you reuse an output directory from 0.3.1, the old chunks will sit next to the new ones, and a glob such as `*.csv` will pick up both.

The zero-padded numbers also mean that an alphabetical sort now puts the chunks in the right order. Before, `chunk_10.csv` sorted ahead of `chunk_2.csv`.

### Exit statuses to check in scripts

- **Status 2:** `--rows` is less than 1. splitlane prints `--rows must be at least 1` and stops. In 0.3.1, `--rows 0` made splitlane loop instead of exiting.
- **Status 3:** splitlane can't decode the input with the given `--encoding`. It names the file and the encoding in the error message. **Chunks written before the error stay on disk**, so a failed run can leave a partial output directory behind. Check for status 3 and discard that output. If the file isn't UTF-8, rerun with the right encoding, for example `--encoding latin-1` for an ISO-8859 export.

## Fixes

### Line breaks inside quoted fields (#42)

A quoted field that contains a line break now stays in one row, as RFC 4180 requires. Before, splitlane ended the row at the line break, so this input:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

came out as three broken rows instead of two. Exports with free-text columns, such as CRM notes, are the files most likely to be affected. If you split files like that, chunks from 0.4.0 can contain different rows from the ones 0.3.1 produced, because 0.3.1 counted each half of a broken row as a separate row.

### A stray quote no longer swallows the rest of the file (#42)

Tracking quotes has a risk. If a file has one unmatched `"`, everything after it could look like a single field. splitlane limits the damage with `--max-row-bytes` (default 65536). When a row grows past that limit, splitlane cuts it there, counts it as truncated, and resumes reading at the next line break. Only that row is damaged, and the rest of the file splits normally.

## New

### Truncated rows are reported

At the end of a run, splitlane now prints how many rows it truncated to stderr:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

The exit status is still 0 when rows are truncated, so a script that needs to catch truncation has to check stderr for this warning. If legitimate rows in your data are longer than the limit, raise `--max-row-bytes`.

## Known issues

- **Recovery after a stray quote can land in the wrong place.** After truncating a row, splitlane resumes at the next line break, even when that line break is inside a quoted field. In that rare case, the row after the damaged one can also come out split.
- **Windows: a chunk file open in another program makes the run crash (#57).** If a chunk from an earlier run is open in Excel, for example, splitlane stops with a `PermissionError` when it tries to overwrite that file. The chunks before it have already been rewritten, and the error doesn't say which ones, so the output directory ends up with a mix of new and old chunks. Close the chunk files, or write to an empty directory, before you run splitlane.
