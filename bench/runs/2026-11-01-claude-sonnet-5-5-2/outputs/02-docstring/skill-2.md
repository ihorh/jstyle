"""Read one CSV row from a text stream and return it as `(row, truncated)`.

`stream` must be a text-mode file-like object. When you open a file, pass
`newline=""` so line endings reach this function unchanged. Each call
consumes one row and leaves the stream at the start of the next, so call it
repeatedly to walk through a file.

A row ends at the first `"\n"` that is not inside double quotes, so a quoted
field can contain line breaks. The terminator is not included in `row`.
Only `"\n"` ends a row, so a `"\r"` before it stays at the end of `row`.
The row is returned as raw text and is not split into fields. To count its
columns, pass it to `count_columns()`.

`max_row_bytes` caps the UTF-8 size of a row, excluding the terminator. It
defaults to `DEFAULT_MAX_ROW_BYTES` (65536). If a row is longer, `row` holds
only the first characters that fit, and `truncated` is `True`. The rest of
that row is discarded up to the next `"\n"`, even one inside quotes, or to
the end of input. A truncated row can end inside an open quote, so don't
assume it parses as valid CSV.

Returns:
    A tuple `(row, truncated)`.

    - `(str, False)` is a complete row. A blank line gives `("", False)`.
      A final row with no trailing newline is also returned this way.
    - `(str, True)` is a row cut off at `max_row_bytes`.
    - `(None, False)` means the stream was already at the end, so there
      are no more rows.

An unclosed quote makes the row run to the end of input, or to
`max_row_bytes`, whichever comes first.
"""
