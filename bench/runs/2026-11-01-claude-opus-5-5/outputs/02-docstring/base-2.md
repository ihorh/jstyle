```python
    """Read one CSV row from a text stream, without parsing it into fields.

    Reads ``stream`` one character at a time until it reaches a newline
    outside double quotes, or the end of input. A newline inside a quoted
    field is part of the row. Every ``"`` character switches between
    quoted and unquoted, so an escaped quote (``""``) leaves the state
    as it was.

    The row comes back as raw text. Quote characters are kept and the
    ending newline is removed. A ``\\r`` before the newline is not
    removed, so if the stream was opened with ``newline=""`` and the
    file uses CRLF line endings, each row ends in ``"\\r"``.

    Args:
        stream: A text-mode file-like object with a ``read(1)`` method.
            Rows are read from its current position, and when the call
            returns the position is just after the row's newline.
        max_row_bytes: The largest row allowed, in bytes of its UTF-8
            encoding, not counting the ending newline. The default is
            ``DEFAULT_MAX_ROW_BYTES`` (65536).

    Returns:
        A tuple ``(row, truncated)``:

        - ``(None, False)`` if the stream is already at end of input.
        - ``(row, False)`` for a complete row. A blank line gives
          ``("", False)``, not ``None``. If the input ends without a
          final newline, the last row is still returned normally.
        - ``(prefix, True)`` if the row is longer than ``max_row_bytes``.
          ``prefix`` is the longest start of the row that fits in the
          limit, and it may stop partway through a quoted field.

    Warning:
        After a row is truncated, the rest of the input is skipped up to
        the next newline, whether or not that newline is inside quotes.
        If the long row had a quoted field with embedded newlines after
        the cut, later calls will return pieces of that row as if they
        were separate rows. In the same way, a quote that is never
        closed makes the rest of the input one row, which is then
        truncated at ``max_row_bytes``.
    """
```
