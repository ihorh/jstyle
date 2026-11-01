# splitlane

Split a large CSV file into smaller files with the same header.

## Install

From a checkout:

```bash
pip install .
```

## Usage

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

This writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on. Each
chunk starts with the input's header row.

Options:

- `--rows N`: rows per chunk, not counting the header. Default 100000.
- `--out DIR`: output directory, created if missing. Default `out`.
- `--max-row-bytes N`: longest row kept whole. Default 65536.
- `--encoding NAME`: input encoding. Default `utf-8`.

## Long rows

A row longer than `--max-row-bytes` (measured in UTF-8 bytes) is not kept whole. splitlane cuts it at the limit, writes the shortened row to the chunk, and skips ahead to the next newline. The cut row is counted, and the rest of the file is processed normally.

This limit also stops an unterminated quote from swallowing the rest of the file. Newlines inside quoted fields stay in the row, so legitimate multi-line fields are fine as long as the row stays under the limit. A stray quote damages one row instead of the whole file.

Truncation is not silent. At the end of a run, the CLI prints a warning to stderr:

```
splitlane: warning: N row(s) longer than 65536 bytes were truncated
```

Check for this message in scripts, because the truncated rows are shortened in the output. If you use the library, `read_row()` returns a flag that says whether the row was truncated, and `split_file()` returns the truncated count along with the list of files written.

If your data has long rows you need to keep, raise `--max-row-bytes`.

Known limitation: after a truncation, the skip goes to the next newline even if that newline is inside quotes. In a bad case the reader may resume in the middle of a real multi-line field.
