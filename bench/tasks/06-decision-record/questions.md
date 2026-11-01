# Questions

1. What was decided? *Track quotes so a quoted newline stays in its field, and
   bound each row by `--max-row-bytes`.*
2. Why not plain quote tracking? *One stray quote made the reader swallow the
   rest of the file as one field.*
3. Why not detect a stray quote by counting lines? *A legitimate notes field
   can span many lines.*
4. How does a user learn that rows were cut? *The CLI prints the count of
   truncated rows. Library callers get the flag from `read_row()`.*
5. What is still open? *The skip after truncation can resume inside a quoted
   multi-line field.*

## Unsupported If Claimed

How often malformed quotes occur, a release date for 0.4.0.
