# Questions

1. What change can break an existing script? *Chunk files are now named
   `part-0001.csv` instead of `chunk_1.csv`.*
2. What happens to quoted fields with newlines now? *They stay in one row.*
3. How does a user learn that rows were truncated? *A warning with the count
   at the end of the run.*
4. What do exit statuses 2 and 3 mean? *2: `--rows` below 1. 3: the input
   cannot be decoded.*
5. Is there a known issue? *Only if the release ships before #57: the Windows
   crash when a chunk file is open in Excel.*

## Unsupported If Claimed

A release date, performance changes, new options.
