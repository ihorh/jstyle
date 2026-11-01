```python
"""Read one CSV record from a text stream, honoring quoted newlines.

Reads characters from ``stream`` until it reaches a newline outside
double quotes, or the end of input. A newline inside a quoted field
belongs to the record and does not end it. The returned text is the raw
record. Fields are not split, quotes and ``""`` escapes are left in place,
and the terminating newline is not included. Any ``"\\r"`` before the
newline is kept. For a CRLF file opened with ``newline=""``, each row
therefore ends in ``"\\r"``.

Args:
    stream: A text-mode file-like object whose ``read(1)`` returns one
        ``str`` character and ``""`` at end of input. Open files with
        ``newline=""`` so newlines inside quoted fields come through
        unchanged. Reading starts at the stream's current position. When
        the call returns, the stream is just past the consumed newline,
        or at end of input.
    max_row_bytes: Largest record size allowed, measured as the UTF-8
        byte length of the record text. The newline is not counted. This
        is always UTF-8, whatever encoding the stream was opened with.

Returns:
    A ``(row, truncated)`` tuple:

    * ``(None, False)``: the stream was already at end of input. This is
      the only end-of-input signal. A blank line gives ``("", False)``,
      not ``None``.
    * ``(row, False)``: a complete record.
    * ``(row, True)``: the record went over ``max_row_bytes``. ``row`` is
      the longest prefix that fits the limit. It may stop in the middle
      of a field and leave a quote unclosed. The rest of the record is
      read and thrown away up to the next newline, **even if that newline
      is inside a quoted field**. If the oversized record has quoted
      newlines past the cut, the text after them is returned by later
      calls as separate, invalid rows.

If a quote is never closed, everything up to end of input is read as
one record. That record is still subject to ``max_row_bytes``.
"""
```
