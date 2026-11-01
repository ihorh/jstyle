```python
"""Read one CSV record from a text stream.

Reads one character at a time, up to and including the next newline that is
not inside double quotes. A newline inside a quoted field stays part of the
record. Quote tracking is basic: every ``"`` switches between inside and
outside quotes, so an escaped ``""`` cancels itself out. The function does
not parse or check fields.

Args:
    stream: A text-mode file-like object whose ``read(1)`` returns ``str``.
        Open files with ``newline=""`` so line endings reach this function
        unchanged. A binary stream will loop forever.
    max_row_bytes: Largest record size allowed, measured as the record's
        UTF-8 encoded length, whatever encoding the stream uses. The
        newline at the end is not counted.

Returns:
    A ``(row, truncated)`` tuple:

    - ``(None, False)`` at end of input, when no characters were read.
    - ``(row, False)`` for a complete record. ``row`` does not include the
      newline that ended it. A ``\\r`` before that newline is *not* removed,
      so CRLF input gives rows that end in ``"\\r"``. A blank line gives
      ``("", False)``, not ``None``. The last record does not need a
      newline after it.
    - ``(row, True)`` when the record went over ``max_row_bytes``. ``row``
      holds the first characters, up to ``max_row_bytes`` bytes, and may
      end partway through a field or inside an open quote. The rest of the
      record is read and thrown away.

Caveats:
    - After truncation, the function skips input up to the next newline
      *without* checking quotes. If the cut happened inside a quoted field
      that contains newlines, the next call starts partway through that
      field and may lose track of quotes for the records after it.
    - A quote that is never closed makes the rest of the input one record,
      which is then truncated at ``max_row_bytes``.
"""
```
