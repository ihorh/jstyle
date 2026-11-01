"""Read one CSV row from a text stream, allowing quoted fields to span lines.

A row ends at the first newline that is not inside double quotes. Newlines inside a quoted field are kept in the returned text. The terminating newline is consumed but not returned. A `\r` before it is not stripped, so open files with `newline=""` and expect `\r` at the end of CRLF rows. Rows are not parsed into fields. Pass the returned text to `csv.reader` or similar.

Args:
    stream: Text-mode file-like object whose `read(1)` returns `str`, and `""` at end of input. The stream is advanced past the row that was read.
    max_row_bytes: Maximum size of a row, measured in UTF-8 bytes and not counting the terminating newline. Defaults to `DEFAULT_MAX_ROW_BYTES` (65536).

Returns:
    A tuple `(row, truncated)`:

    - `(text, False)`: a complete row. A blank line gives `("", False)`.
    - `(text, True)`: the row exceeded `max_row_bytes`. `text` holds only the content read before the limit was passed. The rest of the row is discarded up to the next newline, whether or not that newline is inside quotes. Because of this, the next call may start mid-record if the discarded part contained a quoted newline. `text` may end inside an open quote.
    - `(None, False)`: end of input, with nothing left to read. Use this to stop looping.

    If the input ends without a final newline, the remaining text is returned as a normal row.

Note:
    An unterminated quote makes the row run to the end of input, or until `max_row_bytes` is exceeded.
"""
