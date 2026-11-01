# Questions

1. What happens to a row longer than `--max-row-bytes`? *It is cut at the
   limit, counted, and reported at the end of the run.*
2. How do you keep a long row whole? *Raise `--max-row-bytes`.*
3. Do quoted fields with newlines stay in one row? *Yes.*
4. Did the rest of the README stay as it was? *Check against the original.*

## Unsupported If Claimed

A maximum safe value for `--max-row-bytes`, performance effects of raising it.
