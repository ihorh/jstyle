# 0001: Keep newlines inside quoted fields, and cap row length with `--max-row-bytes`

- Status: accepted. Merged 2026-10-02 and ships in 0.4.0.
- Issue: #42, "Rows with newlines inside quotes get split in two"
- Code: `read_row()` in `src/splitlane/split.py`

## Context

Up to 0.3.x, `read_row()` ended a row at the first newline, even when the
newline was inside a quoted field. devi chose this on purpose in 0.1. A reader
that tracks quotes can be thrown off by one malformed quote. It then takes
everything after that quote, possibly the rest of the file, as a single field.
The 0.1 reader chose "never swallow the file" over "handle quoted newlines".

That choice broke valid input. RFC 4180 allows a quoted field to contain line
breaks, and CRM exports with a free-text `notes` column often include them. For
this input:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

splitlane wrote three data rows instead of two. The second of those rows had
the wrong number of columns, so the downstream importer rejected the whole
chunk. Two teams were blocked by this: billing and support analytics. Neither
team had seen a malformed quote in their exports.

The first fix tracked quotes with no limit, and it showed that the 0.1 concern
was real. In a test file of 400,000 rows with one stray `"` in row 12, the
reader took everything after row 12 as one field. It wrote a chunk that held
the header and one enormous row.

## Decision

`read_row()` tracks quotes, so a newline inside a quoted field stays in the
field. This matches RFC 4180 and the way spreadsheets read CSV.

To stop a stray quote from swallowing the file, the existing `--max-row-bytes`
limit also bounds quoted fields. The default is 65536 bytes. When a row grows
past the limit, `read_row()`:

1. stops and returns what it has read so far as the row,
2. skips the input up to the next newline, or to the end of the input,
3. marks the row as truncated.

A real multi-line note stays far below the limit. A stray quote reaches it,
damages one row, and the reader picks up again at the next line.

Truncation is never silent. `read_row()` returns a `(row, truncated)` pair, and
`split_file()` returns the number of truncated rows. When that number is not
zero, the CLI prints this warning to stderr at the end of the run:

```
splitlane: warning: N row(s) longer than M bytes were truncated
```

The billing and support analytics teams check for this message in their
scripts. Their importer won't notice a shortened row on its own. If you change
the wording, you break their check, so treat the message as part of the
interface.

### Rejected: limit a quoted field by line count

tomasz suggested treating a quoted field as broken once it ran past some number
of lines. We rejected this because a legitimate notes field can have many
lines. A byte limit separates the two cases better, and the option already
existed.

## Consequences

- Quoted fields that contain newlines now come through intact.
- One malformed quote damages at most one row, plus whatever the skip in step 2
  discards. It no longer damages the rest of the file.
- A legitimate row longer than `--max-row-bytes` gets truncated too, because
  the reader can't tell it from a stray quote. Users with very long fields need
  to raise the limit.
- Known limitation, raised by tomasz and left for later: the skip in step 2
  stops at the next newline even when that newline is inside quotes. In a bad
  case, the reader resumes in the middle of a real multi-line field.

Two more effects follow from the code. The issue thread did not discuss them:

- After the skip, `read_row()` starts the next row as unquoted. If it resumed
  inside a quoted field, that field's closing `"` opens a new quoted run. The
  rows after it can then be merged until the limit is reached again. So the
  damage can spread past one row.
- A truncated row usually ends inside an open quote, and splitlane writes it to
  the chunk as is. A CSV parser that reads that chunk may treat the rows after
  it as part of the open field. The warning tells the user that something is
  wrong, but the chunk itself is not valid CSV.
