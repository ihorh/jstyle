```python
"""Read one CSV row from a text stream.

A row ends at the first newline outside double quotes. Newlines inside a
quoted field stay part of the row. The function doesn't include the
ending newline in the row it returns. It doesn't parse fields or remove
quotes either, so you get the row's raw text. To split it into fields,
pass it to a CSV parser.

The stream must be in text mode. The function reads it one character at
a time and stops right after the row's newline, so the next call starts
on the next row. A carriage return doesn't end a row. If you open a
CRLF file with ``newline=""``, each row comes back with a trailing
``"\\r"``.

Args:
    stream: A text-mode file object, or anything else with a ``read(1)``
        method that returns ``""`` at the end of input.
    max_row_bytes: The largest row to return in full. The function
        measures the row in UTF-8 bytes, whatever the stream's encoding,
        and doesn't count the ending newline. A row of exactly this size
        comes back whole.

Returns:
    A ``(row, truncated)`` tuple:

    - ``(text, False)``: a complete row. A blank line gives ``("", False)``.
      The last row of the input doesn't need a trailing newline.
    - ``(text, True)``: the row was longer than ``max_row_bytes``. ``text``
      holds as many whole characters from the start of the row as fit in
      the limit. The function discards the rest of the input up to the
      next newline.
    - ``(None, False)``: no input was left. Check for ``None`` rather than
      for a falsy value, because a blank line also returns ``""``.

Note:
    When a row is too long, the function discards input up to the next
    newline even if that newline is inside a quoted field. If the cut
    falls inside a multi-line quoted field, the next call starts partway
    through that field. Rows read after that point may be split in the
    wrong places until the quotes line up again.
"""
```
