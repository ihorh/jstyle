# Questions

1. What change is proposed? *Drop the row pre-count and show rows processed
   and chunks written instead of a percentage, so the input is read once.*
2. Why? *The pre-count reads the whole input twice.*
3. What do users lose? *The percentage and the ETA.*
4. What middle ground exists, and what is its weakness? *Estimate the
   percentage from bytes read over file size. It is off on files with long
   rows.*

## Unsupported If Claimed

A measured speedup or timing, user survey results.
