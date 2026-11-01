# Questions

1. What was the original problem in #42? *Quoted fields with newlines were
   split into two rows.*
2. What shipped? *Quote tracking, bounded by `--max-row-bytes`, with truncated
   rows counted and reported.*
3. What is Sam's follow-up? *After a truncation, the reader skips to the next
   newline even inside quotes, so it can resync in the middle of a real
   multi-line field.*
4. How urgent is it? *Not blocking. tomasz called it probably rare.*

## Unsupported If Claimed

How often the follow-up case happens, a deadline.
