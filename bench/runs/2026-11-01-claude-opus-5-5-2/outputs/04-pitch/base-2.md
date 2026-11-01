Before this merges, I'd like to suggest a change to how the progress display gets its total.

As I understand it, the branch counts every row up front so it can show a percentage. That means splitlane reads the whole input twice. Because of the #42 quoting fix, the count can't just count newlines. Notes fields can contain them, so the first pass has to parse rows the same way `split_file()` does. On our biggest exports that first pass takes a noticeable amount of time before any chunk is written. I haven't timed it, so I can't give you a number. I'm happy to measure it on a large export if that would help.

**What I'm suggesting:** drop the pre-count and show live counters instead of a percentage, something like `1,240,000 rows processed, 13 chunks written`. Then we read the input only once. `split_file()` already reads row by row, so I think the whole change is in the branch's CLI code. Nothing in `split.py` has to change apart from passing progress out to the CLI.

**What we lose:** the percentage and the ETA. I know you've heard from users who want the bar, and I'm not trying to dismiss that. It's a real cost.

**A possible middle ground:** estimate the percentage from bytes read divided by file size. It needs no pre-count, so we keep one pass and still show something like a bar. The open question is whether it's accurate enough. Row lengths vary, so a file with long notes in some sections would make the bar speed up and slow down. It would still always move forward and finish at 100%, so it might be good enough. You've talked to the users who asked for the bar, so you're better placed than I am to judge that.

Here's what I'd suggest, but I'm open to changing it:
1. Use the counters by default.
2. Use the bytes-based percentage if we decide the estimate is good enough.
3. Keep the exact pre-count only if users really need the exact number, maybe behind a flag.

Can we settle this before the branch merges? I'm happy to pair on it or write the CLI change myself if that helps.
