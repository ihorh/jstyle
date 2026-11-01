# Questions

Each answer comes from the world files. A cold reader answers from the output
alone.

1. What does splitlane do? *Splits a large CSV file into smaller files that
   each start with the input's header row.*
2. What are the output files named? *`part-0001.csv`, `part-0002.csv`, and so
   on, in the `--out` directory.*
3. What happens to a row longer than `--max-row-bytes`? *It is cut at the
   limit, counted as truncated, and the CLI reports the count at the end.*
4. How do you install it? *`pip install .` from a checkout.*

## Unsupported If Claimed

Performance figures, supported Python versions, a license, a PyPI package,
Windows support.
