# Questions

1. What does `read_row()` return? *A tuple `(row, truncated)`: the row text
   without its line ending, and whether it was cut.*
2. How does a caller detect the end of input? *`row` is `None`, with
   `truncated` False.*
3. What happens when a row exceeds `max_row_bytes`? *The returned row holds
   the bytes up to the limit, `truncated` is True, and the stream is advanced
   past the next newline.*
4. Does a newline inside quotes end the row? *No. It stays in the field.*
5. What can go wrong after a truncation? *The skip goes to the next newline
   even inside quotes, so it can resume in the middle of a multi-line field.*

## Unsupported If Claimed

Raising an exception on truncation, a performance guarantee.
