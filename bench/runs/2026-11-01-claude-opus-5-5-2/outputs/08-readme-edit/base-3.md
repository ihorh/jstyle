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
- `--max-row-bytes N`: longest row kept whole. Longer rows are truncated (see
  [Long rows](#long-rows)). Default 65536.
- `--encoding NAME`: input encoding. Default `utf-8`.

## Long rows

splitlane does not keep a row whole if it is longer than `--max-row-bytes`.
It writes the first `--max-row-bytes` bytes of the row (or slightly fewer) to
the chunk, drops the rest of the row up to the next newline, and moves on.
The run still exits with status 0. The only sign that this happened is a
warning on stderr at the end of the run:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

If you run splitlane from a script, check stderr for this warning. The exit
status will not tell you.

Things to know about truncated rows:

- A truncated row is often not valid CSV anymore. It can have fewer columns
  than the header, or a quote that is never closed.
- After the cut, splitlane skips to the next newline, even if that newline is
  inside a quoted field. If a long row has a quoted newline after the cut, the
  text after that newline is read as a new row.
- If a quote is never closed, the row runs on until it reaches the limit, and
  then it is truncated the same way.
- Row length is counted in UTF-8 bytes, whatever `--encoding` is set to.
- The header row has the same limit, but a truncated header is not counted in
  the warning.

If your rows need to stay whole, raise the limit, for example
`--max-row-bytes 1048576`.
