```python
"""Read one CSV record from a text stream.

Reads characters from ``stream`` until it reaches a newline that is not
inside a double-quoted field, or until end of input. Newlines inside
quoted fields stay in the returned row, so one record can span several
physical lines. Quote state flips on every ``"`` character, so a stray
quote in an unquoted field can make the rest of the input look like one
quoted field.

Args:
    stream: A text-mode file-like object, such as one returned by
        ``open(path, newline="")``. It is read one character at a time
        with ``stream.read(1)``. Binary streams are not supported.
    max_row_bytes: The maximum size of a row, measured as its UTF-8
        encoded length no matter what encoding the stream uses. The
        terminating newline does not count toward the limit.

Returns:
    A ``(row, truncated)`` tuple:

    - ``(None, False)`` at end of input, when no characters were read.
    - ``(row, False)`` for a complete record. ``row`` does not include
      the terminating newline. If the stream keeps ``\\r\\n`` line
      endings (``newline=""``), ``row`` ends with ``"\\r"``. A blank
      line returns ``("", False)``, not ``None``. A final record with
      no trailing newline is returned normally.
    - ``(row, True)`` when the record was longer than ``max_row_bytes``.
      ``row`` is the first ``max_row_bytes`` bytes or fewer, and it can
      end inside a quoted field.

Truncation:
    After truncating a row, the rest of the input is discarded up to and
    including the next newline, *whether or not that newline is inside
    quotes*. If the oversized record has a quoted field with an embedded
    newline after the cut point, the text after that newline is returned
    by the next call as if it were a new row. Callers that need correct
    record boundaries should treat rows that follow a truncated row as
    unreliable, or set ``max_row_bytes`` high enough that truncation
    does not happen.
"""
```
