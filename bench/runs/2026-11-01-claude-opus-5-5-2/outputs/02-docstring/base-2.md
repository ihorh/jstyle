```python
"""Read one CSV record from a text stream, without its line terminator.

Reads character by character up to the next newline that is not inside
double quotes, so a quoted field can contain newlines. The terminating
"\n" is consumed but not included. A "\r" before it is kept, so CRLF
input leaves a trailing "\r" on each row. Open files with ``newline=""``
so that quoted newlines and "\r" reach this function unchanged.

Args:
    stream: A text-mode file-like object whose ``read(1)`` returns a str
        and returns "" at end of input. The stream is left positioned at
        the start of the next record.
    max_row_bytes: The maximum row size in bytes, measured by encoding the
        row as UTF-8 whatever the stream's encoding is. Defaults to
        ``DEFAULT_MAX_ROW_BYTES`` (65536).

Returns:
    A ``(row, truncated)`` tuple:

    - ``(None, False)`` at end of input, when there are no characters left
      to read. A blank line returns ``("", False)``, not ``None``.
    - ``(row, False)`` for a complete record. The last record is returned
      even if it has no trailing newline or has an unclosed quote.
    - ``(prefix, True)`` if the record exceeds ``max_row_bytes``. ``prefix``
      is the longest leading part that fits within the limit, so it can end
      partway through a field and leave a quote unclosed. The rest of the
      record is discarded up to and including the next "\n", whether or not
      that newline is inside quotes. If the record had a quoted newline after
      the cut, the text after that newline is returned by later calls as if
      it were separate records.

Quote tracking counts every '"' character, so an escaped quote ("")
works correctly. The function does not parse fields. Use
``count_columns()`` or the ``csv`` module to split the returned row.
"""
```
