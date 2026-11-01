# splitlane

splitlane splits a large CSV file into smaller files with a fixed number of
rows each, and copies the header row into every one. It reads the input one row
at a time, so memory doesn't limit the file size. It needs nothing outside the
Python standard library.

The `main` branch holds 0.4.0, which isn't released yet. That version renames
the output files and changes how quoted fields are read. See
[Upgrading from 0.3](#upgrading-from-03).

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
chunk starts with the input's header row and holds up to 50000 data rows after
it.

Options:

- `--rows N`: data rows per chunk, not counting the header. Default 100000.
- `--out DIR`: output directory, created if missing. Default `out`.
- `--max-row-bytes N`: rows longer than this are cut at this length. Default
  65536. See [Long rows and stray quotes](#long-rows-and-stray-quotes).
- `--encoding NAME`: the input's encoding. Any name Python accepts works, such
  as `cp1252` or `latin-1`. Default `utf-8`. splitlane always writes chunks in
  UTF-8, whatever the input's encoding.

splitlane prints progress and warnings to stderr and nothing to stdout. It
exits with one of these statuses:

| Status | Meaning |
| ------ | ------- |
| 0 | The input was split. Check stderr for a truncation warning. |
| 1 | An unexpected error, such as a chunk that can't be written. Python prints a traceback. |
| 2 | Bad arguments, such as `--rows 0`. |
| 3 | The input couldn't be decoded with `--encoding`. |

If a file exported from Excel or an older system fails with status 3, it is
probably in Windows-1252 rather than UTF-8. Run splitlane again with
`--encoding cp1252`.

## Quoted fields

A field in double quotes can contain line breaks, as RFC 4180 allows, and
splitlane keeps such a field in one row. This input has two data rows, not
three:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

Apart from tracking quotes, splitlane doesn't parse or check fields. It doesn't
count columns, and it writes each row out as it read it, including the input's
line endings.

## Long rows and stray quotes

A single unmatched `"` would make every line after it look like part of one
quoted field. So that a stray quote can't swallow the rest of the file,
splitlane caps the length of each row at `--max-row-bytes`, measured as UTF-8.
When a row grows past the cap, splitlane keeps the part up to the cap, discards
the rest of that line, and continues from the next line break.

A truncated row is not lost silently. At the end of the run splitlane prints:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

The exit status is still 0. If your pipeline can't accept shortened rows, check
stderr for this warning. If your data has legitimate rows longer than 64 KiB,
raise `--max-row-bytes`.

The recovery isn't perfect. splitlane resumes at the next line break even when
that line break is inside a real quoted field, so a few rows after a truncated
one can be split wrongly too. Each damaged row is still bounded by the cap.

## Things to know before you rely on it

- **Old chunks are not removed.** splitlane overwrites a chunk that has the
  same name but leaves every other file in the output directory alone. If an
  earlier run wrote more chunks than this one, the extra chunks stay. Use an
  empty directory for each run.
- **A failed run leaves partial output.** If splitlane stops with an error, the
  chunks it wrote before the error stay on disk, and the last one is
  incomplete.
- **Windows: a chunk open in another program stops the run.** If a chunk file
  from an earlier run is open in Excel, splitlane crashes with
  `PermissionError` when it tries to overwrite that file. The chunks before it
  have already been rewritten and the ones after it haven't, so the directory
  holds a mix of old and new chunks. This is tracked in #57 and isn't fixed
  yet.
- **Past 9999 chunks, names stop sorting in order.** The number has four
  digits of padding, so chunk 10000 is `part-10000.csv`.
- **An input with only a header produces no chunks** and exits with status 0.

## Use as a library

```python
from splitlane.split import split_file

written, truncated = split_file("data/export.csv", 50000, "chunks",
                                max_row_bytes=65536, encoding="utf-8")
```

`written` is the list of chunk paths in order, and `truncated` is the number of
rows cut at `max_row_bytes`. `split_file()` prints nothing, so check
`truncated` yourself. A decoding failure raises `UnicodeDecodeError` and leaves
partial output, as the CLI does.

## Upgrading from 0.3

- Chunks are now named `part-0001.csv`, `part-0002.csv`, and so on, instead of
  `chunk_1.csv`, `chunk_2.csv`. The zero padding makes them sort in order.
  Update any script that looks for the old names.
- A line break inside a quoted field no longer ends the row (#42).
- `--rows 0` now exits with status 2 instead of looping.
- The truncation warning and exit status 3 are new.

See [CHANGELOG.md](CHANGELOG.md) for the full list.
