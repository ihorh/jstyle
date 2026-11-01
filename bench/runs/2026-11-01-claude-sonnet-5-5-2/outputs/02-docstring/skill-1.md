"""Read one CSV row from a text stream and return it with a truncation flag.

A row ends at the first newline that is not inside double quotes, so a quoted
field can contain newlines. The row is returned as raw text. The terminating
newline is not included, and the quotes are not parsed or removed. Open files
with `newline=""` so line endings reach this function unchanged. With CRLF
input, the row keeps its trailing `"\r"`.

Rows longer than `max_row_bytes` are cut short. The limit is measured in
UTF-8 bytes, and it counts quote characters and newlines inside quotes. The
returned text is cut at a character boundary, so it never exceeds the limit.
The rest of that row is read and discarded up to the next newline, whether or
not the newline is quoted. After a truncation the stream is therefore
positioned at the start of the next line. The truncated text can end inside an
open quote, so don't assume its quotes are balanced.

Args:
    stream: A text stream (such as a file opened in text mode) with a
        `read(1)` method. It is read one character at a time, and its
        position advances past the row.
    max_row_bytes: The most UTF-8 bytes of row text to keep. Defaults to
        `DEFAULT_MAX_ROW_BYTES` (65536).

Returns:
    A tuple `(row, truncated)`.

    - `(text, False)`: a complete row. A blank line gives `("", False)`.
      A final row with no trailing newline is returned like any other.
    - `(text, True)`: the row exceeded `max_row_bytes`, and `text` holds
      only its first part.
    - `(None, False)`: the stream is exhausted and no row remains. Call
      `read_row()` in a loop and stop when `row is None`.
"""
