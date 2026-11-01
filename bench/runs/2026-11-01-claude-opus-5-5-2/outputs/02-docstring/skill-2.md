```python
"""Read one CSV record from a text stream and return it as raw text.

The record ends at the first newline that is not inside double quotes, so a
quoted field can contain newlines. The returned text has no trailing newline.
`read_row()` does not split the record into fields or remove quotes, so the
caller gets the line as it appears in the input. It reads one character at a
time, and the stream is left positioned at the start of the next record.

Args:
    stream: A text-mode file object, or any object whose `read(1)` returns a
        one-character `str` and returns `""` at end of input. If you open a
        file with `newline=""`, as `split_file()` does, Windows line endings
        are kept as they are, and each returned row ends with `"\\r"`.
    max_row_bytes: The maximum size of a record, counted as the number of
        bytes its text takes when encoded as UTF-8. The newline that ends the
        record does not count toward this limit. Defaults to 65536.

Returns:
    A tuple `(row, truncated)`:

    - `(None, False)` when the stream is already at end of input. A blank
      line returns `("", False)`, so check for `None` to detect the end.
    - `(row, False)` for a complete record. The last record is returned even
      if the input does not end with a newline.
    - `(row, True)` when the record is longer than `max_row_bytes`. In that
      case `row` holds only the start of the record, at most `max_row_bytes`
      bytes, and the rest of the record is read and discarded.

Caveats:
    - When a record is too long, `read_row()` discards input only up to the
      next newline, even if that newline is inside a quoted field. A long
      record that contains quoted newlines is not discarded completely. Its
      remaining lines come back from the following calls as if they were
      separate records.
    - Every `"` character switches the quoted state on or off, wherever it
      appears. A stray quote in an unquoted field therefore makes later
      newlines count as part of the field. An unclosed quote makes the rest
      of the input one record, until `max_row_bytes` cuts it off.
"""
```
