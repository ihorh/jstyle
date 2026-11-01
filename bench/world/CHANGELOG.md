# Changelog

## Unreleased (0.4.0)

- Fix: `--rows 0` now exits with status 2 and a message, instead of looping.
- Fix: a quoted field containing a newline stays in one row (#42).
- Fix: an unterminated quote no longer swallows the rest of the file. The row
  stops at `--max-row-bytes` and counts as truncated (#42).
- Change output file naming to a zero-padded scheme.
- Report the number of truncated rows at the end of a run.
- Exit with status 3 when the input cannot be decoded.
- Internal: move column counting into `split.py`.

## 0.3.1

- Fix: the header row was missing from every chunk after the first.

## 0.3.0

- Add `--encoding`.
- Add `--max-row-bytes`.
