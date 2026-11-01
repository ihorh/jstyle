```python
"""Read one CSV row from a text stream and return it with a truncation flag.

Reads characters from `stream` up to the next newline that is not inside a
double-quoted field. Newlines inside quotes are kept as part of the row. The
terminating newline is consumed but not included in the returned string. A
carriage return before it is not stripped, so open files with `newline=""`
and expect a trailing "\r" on CRLF input. Fields are not parsed or unquoted.
Quote state is tracked by toggling on every `"` character, so escaped quotes
(`""`) are handled correctly.

Call it repeatedly on the same stream to read consecutive rows. Each call
leaves the stream positioned at the start of the next row.

Args:
    stream: A text-mode file-like object whose `read(1)` returns one
        character as `str` and returns `""` at end of input.
    max_row_bytes: Maximum size of a row, measured in UTF-8 bytes of the
        returned text (not characters). Defaults to
        `DEFAULT_MAX_ROW_BYTES` (65536).

Returns:
    A `(row, truncated)` tuple.

    - `(row, False)`: a complete row. `row` may be `""` for a blank line.
      A final row with no trailing newline is returned normally.
    - `(row, True)`: the row exceeded `max_row_bytes`. `row` holds only the
      leading characters that fit within the limit. The rest of the row is
      discarded, up to and including the next newline, whether or not that
      newline is inside quotes. The truncated `row` can therefore have
      unbalanced quotes and should not be assumed to be valid CSV.
    - `(None, False)`: end of input was reached with nothing left to read.
      This is the only case where `row` is `None`, which distinguishes it
      from a blank line.

Note:
    If a quoted field is never closed, the rest of the input is read as one
    row, or is truncated at `max_row_bytes`.
"""
```
