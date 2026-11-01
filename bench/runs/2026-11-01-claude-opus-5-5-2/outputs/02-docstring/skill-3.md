```python
"""Read one CSV row from a text stream and return it with a truncation flag.

A row ends at the first newline that is not inside double quotes, so a quoted
field can contain newlines. Every `"` character switches quoting on or off, so
a stray quote in an unquoted field (for example `5" pipe`) makes the rest of the
input parse wrongly. The stream is read one character at a time and is left at
the start of the next row.

Args:
    stream: A text-mode file object, or any object whose `read(1)` returns a
        one-character `str` and returns `""` at end of input.
    max_row_bytes: The largest row to return in full, measured in UTF-8 bytes
        without the ending newline. Defaults to 65536.

Returns:
    A tuple `(row, truncated)`:

    - `row` is the row text without its ending newline, or `None` when the
      stream has no more input. A blank line gives `""`, not `None`, so stop
      reading only on `None`. A final row with no ending newline is still
      returned. If the stream was opened with `newline=""`, rows from a file
      with CRLF line endings keep their trailing `"\\r"`.
    - `truncated` is `True` when the row was longer than `max_row_bytes`. In
      that case `row` holds only the part of the row that fits, and the rest
      is read and discarded.

    When a row is too long, the rest of it is skipped only up to the next
    newline, even if that newline is inside a quoted field. So if a long row
    has a quoted newline after the cutoff, the next call starts partway
    through that row and returns the rest of it as though it were a separate
    row.
"""
```
