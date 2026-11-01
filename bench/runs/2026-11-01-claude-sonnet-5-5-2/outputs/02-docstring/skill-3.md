```python
"""Read one CSV row from a text stream and return it as raw text.

The row is returned unparsed, without its line terminator, so you can pass
it to `csv.reader` or `count_columns()`. A newline ends the row unless it
falls inside double quotes, so a quoted field can span several lines. Quotes
are only tracked, never removed. A doubled quote (`""`) inside a field
toggles the state twice and leaves it unchanged, as CSV expects.

Call it repeatedly to walk through a file. Each call consumes exactly one
row, including its newline, so the next call starts at the following row.

Args:
    stream: A text stream whose `read(1)` returns one character, such as a
        file opened with `newline=""`. With that setting, a CRLF file keeps
        its `\r` at the end of each returned row. Otherwise Python converts
        line endings before this function sees them.
    max_row_bytes: The most UTF-8 bytes a row may hold, counted without the
        terminating newline. Newlines inside quotes do count. Defaults to
        `DEFAULT_MAX_ROW_BYTES` (65536).

Returns:
    A tuple `(row, truncated)`.

    - `(row, False)`: a complete row. A blank line gives `("", False)`.
      The last row is returned even when the input has no final newline.
    - `(partial_row, True)`: the row was longer than `max_row_bytes`.
      `partial_row` holds the characters read before the limit, so it is
      cut off mid-row and may have an unclosed quote. The rest of the row
      is discarded up to the next newline, or the end of input. That
      search ignores quotes, so a newline inside a quoted field ends the
      skip early, and the remainder of that record is read as the next
      row.
    - `(None, False)`: the stream was already at the end of input.

    An opening quote that is never closed makes the row run to the end of
    input, or to the size limit.
"""
```
