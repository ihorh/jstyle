# Streaming Rewrite: Rough Notes

tomasz, 2026-10-20. Not a proposal yet, just notes.

- devi's `progress-bar` branch, not merged yet, counts all rows before
  splitting, to show a percentage. That means reading the whole input twice.
- On the biggest exports the first pass alone takes a while. I didn't time it.
- Idea: drop the pre-count. Show "rows processed" and chunks written instead of
  a percentage. One pass over the input.
- `split_file()` already reads row by row, so the change is all in the branch's
  CLI code.
- Cost: no percentage, no ETA. Some users like the bar.
- devi wrote the progress bar and has said before that users ask for it. She'll
  push back.
- Possible middle ground: estimate the percentage from bytes read divided by
  file size. Needs no pre-count. Is the estimate accurate enough? Rows vary in
  length, so it's off on files with long notes.
- Want to pitch this to devi before her branch merges.
