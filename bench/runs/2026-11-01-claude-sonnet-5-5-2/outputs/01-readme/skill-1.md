# splitlane

splitlane splits a large CSV file into smaller CSV files. Every output file starts with the input's header row, so each chunk can be loaded on its own. It's a command-line tool written in Python, and it uses only the standard library.

## Install

splitlane is installed from a checkout:

```bash
pip install .
```

## Usage

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

This writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on. The last chunk holds whatever rows remain.

| Option | Meaning | Default |
| --- | --- | --- |
| `--rows N` | Data rows per chunk, not counting the header | 100000 |
| `--out DIR` | Output directory, created if missing | `out` |
| `--max-row-bytes N` | Longest row kept whole (see below) | 65536 |
| `--encoding NAME` | Encoding of the input file | `utf-8` |

Progress and warnings go to stderr, and nothing is written to stdout. The exit status is 0 on success, 2 for a bad option such as `--rows 0`, and 3 if the input can't be decoded with `--encoding`.

## How it handles quoted fields

A quoted field can contain line breaks, as RFC 4180 allows. Notes columns in CRM exports often do. splitlane keeps such a field inside one row, so a record is never cut in half at a chunk boundary or split into two broken rows.

Following quotes has a risk. One stray `"` in a file could otherwise make the reader treat everything after it as a single field. To prevent that, splitlane stops reading a row once it passes `--max-row-bytes`. It cuts the row there, skips ahead to the next line break, and carries on. A real multi-line note is far below the default limit, so only a malformed row gets cut.

A cut row is not silent. At the end of the run splitlane prints a warning with the number of truncated rows:

```
splitlane: warning: 1 row(s) longer than 65536 bytes were truncated
```

If your files have legitimately huge fields, raise `--max-row-bytes`. If a downstream importer can't detect a shortened row, check for that warning in your scripts.

## Limitations

- **Truncation can resync in the wrong place.** After cutting a row, splitlane resumes at the next line break even if that break is inside quotes. In a bad case it could restart in the middle of a real multi-line field. This should be rare, and it is a known follow-up from [#42](issues/42-quoting.md).
- **Output is always UTF-8**, whatever `--encoding` the input uses.
- **A failed run can leave partial output.** If decoding fails partway through, the chunks written so far stay in the output directory. Delete them before you retry.
- **Existing files are overwritten, and stale ones stay.** A rerun replaces `part-NNNN.csv` files with the same names. If the new run produces fewer chunks than an earlier one, the extra old files remain in the directory.
- **Windows: an open chunk file crashes the run (#57).** If a chunk from an earlier run is open in Excel, splitlane stops with a `PermissionError` when it tries to overwrite that file. Chunks before it have already been written and the error doesn't say which, so you end up with a mix of old and new files. Close the files or use a fresh `--out` directory. This is open as of the 0.4.0 release notes.

## Changes

See [CHANGELOG.md](CHANGELOG.md). Version 0.4.0 is the first to follow quoted newlines, report truncated rows, and use the exit codes above. It also changed the output names to the zero-padded `part-0001.csv` form. Earlier versions used `chunk_1.csv`, so update any pipeline that matches those names.
