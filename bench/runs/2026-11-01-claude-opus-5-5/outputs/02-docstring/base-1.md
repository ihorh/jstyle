```python
"""Read one CSV record from a text stream and return it as raw text.

Reads characters from ``stream`` up to the next newline that is not inside
a double-quoted field, so a quoted field can contain newlines. The text
comes back exactly as it appears in the input: quotes are kept and fields
are not split. Use ``csv.reader`` on the result if you need the fields.

Args:
    stream: A text-mode file-like object (``read(1)`` must return ``str``,
        and ``""`` at end of input). It is consumed in place, so the next
        call picks up at the following record.
    max_row_bytes: Largest record allowed, measured as the UTF-8 encoded
        size of its text, not counting the newline at the end. The size is
        always measured in UTF-8, whatever encoding the stream was opened
        with.

Returns:
    A ``(row, truncated)`` tuple:

    * ``(None, False)`` when the stream is already at end of input.
    * ``(row, False)`` for a complete record. ``row`` does not include the
      newline at the end. A final record with no newline after it is
      returned the same way. A blank line gives ``("", False)``, not
      ``None``.
    * ``(row, True)`` when the record is longer than ``max_row_bytes``.
      ``row`` holds the first ``max_row_bytes`` bytes of the record or
      fewer, so it may stop partway through a field or leave a quote
      unclosed. The rest of the line is read and thrown away.

Caveats:
    * Only ``"\\n"`` ends a record. With a stream opened using
      ``newline=""``, CRLF input leaves a trailing ``"\\r"`` on ``row``,
      and line endings that are a bare ``"\\r"`` are never recognized.
    * When a record is truncated, the rest is discarded up to the next
      ``"\\n"`` even if that newline is inside a quoted field. If an
      oversized record has a quoted multi-line field, the part after that
      newline is returned by the next call as if it were a separate
      record, and the records that follow it may be split in the wrong
      places.
"""
```
