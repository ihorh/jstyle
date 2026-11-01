# splitlane

Split a large CSV file into smaller CSV files, each starting with the original header row.

splitlane reads the input one character at a time, so memory use does not grow with the file size. It keeps a quoted field that contains line breaks inside a single row, as RFC 4180 specifies. If the quoting is malformed, it limits the damage to one row instead of letting a stray quote swallow the rest of the file.

## Status

The current release is 0.3.1. Version 0.4.0 is not released yet. It adds the quoted-newline handling, the truncation report and the exit codes described below. The 0.4.0 release is blocked on a Windows-only bug (see [Known issues](#known-issues)).

## Install

splitlane is installed from a checkout:

```bash
git clone <this repository's URL>
cd splitlane
pip install .
```

## Usage

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

This writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on. Each chunk starts with the input's header row and holds up to 50,000 data rows. The last chunk holds whatever is left.

| Option | Meaning | Default |
| --- | --- | --- |
| `--rows N` | Data rows per chunk, not counting the header. Must be at least 1. | 100000 |
| `--out DIR` | Output directory. Created if missing. | `out` |
| `--max-row-bytes N` | Longest row kept whole, in bytes. | 65536 |
| `--encoding NAME` | Encoding of the input file. | `utf-8` |

Progress and warnings go to stderr. The chunks are always written as UTF-8, whatever the input encoding.

### Exit codes

These apply to 0.4.0.

| Code | Meaning |
| --- | --- |
| 0 | Success. Check stderr for a truncation warning (see below). |
| 2 | Invalid usage, such as `--rows 0`. |
| 3 | The input could not be decoded with the chosen encoding. |

If you get code 3, pass the file's real encoding, for example `--encoding latin-1`. Chunks written before the bad byte was reached stay in the output directory, so delete them before you run again.

## Quoted fields and truncated rows

In 0.4.0, a newline inside a quoted field stays in its row. Take this input:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

It produces two data rows, not three.

Tracking quotes has a risk. One unmatched `"` would otherwise make the reader treat everything after it as a single field. To prevent that, splitlane stops reading a row once it exceeds `--max-row-bytes`, keeps the part it has read, and skips ahead to the next newline. At the end of the run it prints a warning:

```
splitlane: warning: 1 row(s) longer than 65536 bytes were truncated
```

A truncated row is shortened, and a downstream importer will not notice that. If your pipeline cannot tolerate lost data, check stderr for that warning. Raise `--max-row-bytes` if your data has legitimately long rows.

## Known issues

- **Windows: overwriting chunks that are open in Excel (#57).** If a chunk from an earlier run is open in Excel, splitlane crashes with `PermissionError` when it tries to overwrite that file. Chunks before it have already been written, and the error does not say which. You end up with a mix of old and new chunks. Close the files, or write to a fresh `--out` directory. This is the reason 0.4.0 is on hold. A real fix would write to a temporary directory and move the chunks into place at the end.
- **Resync after truncation.** After cutting a row, splitlane skips to the next newline even if that newline is inside quotes. In rare cases it can resume in the middle of a multi-line field.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
