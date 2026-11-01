"""Read one CSV row from a text stream.

A row ends at the first newline that is not inside a double-quoted field, so quoted fields may contain embedded newlines. A `"` toggles the quoted state, so an escaped quote (`""`) is handled correctly. The terminating newline is consumed but not included in the result. If the stream was opened without newline translation (`newline=""`), a `\r` before the `\n` stays at the end of the row.

Rows longer than `max_row_bytes` are truncated. The size is measured in UTF-8 bytes, not characters. When a row exceeds the limit, the function returns the first `max_row_bytes` bytes' worth of characters. It then discards the rest of the row, up to and including the next newline, or to the end of input. That newline ends the discarded text whether or not it is inside quotes. A truncated row can therefore have unbalanced quotes, and its content is incomplete. Don't treat it as valid data.

Args:
    stream: A text-mode file-like object whose `read(1)` returns one character, or `""` at end of input. The stream is advanced past the row.
    max_row_bytes: Maximum size of a returned row, in UTF-8 bytes. Defaults to `DEFAULT_MAX_ROW_BYTES` (65536).

Returns:
    A `(row, truncated)` tuple.

    - `row` is the row text without its line terminator, or `None` if the stream was already at end of input. A blank line returns `""`, not `None`, so compare with `None` to detect the end.
    - `truncated` is `True` if the row exceeded `max_row_bytes` and was cut short, otherwise `False`.

    A final row with no trailing newline is returned normally. The next call returns `(None, False)`.
"""
