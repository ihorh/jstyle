Hey devi, before this merges I'd like to float a change. Feel free to say no.

As I read the branch, it counts every row before splitting so it can show a percentage. That means we read the whole input twice. On our biggest exports the counting pass on its own takes a noticeable chunk of time. I haven't timed it yet, so I don't have numbers. I'll get some if you think this is worth pursuing.

**Proposal:** drop the pre-count and make it one pass. Instead of a percentage, show a live count of rows processed and chunks written. `split_file()` already reads row by row, so most of this should be CLI-side. It'll need some way to report progress while it runs, since right now it only returns at the end. You know how the branch is wired better than I do.

**What we'd lose:** the percentage and the ETA. I know you've heard from users that they want the bar, and I don't want to throw that away lightly.

**Possible middle ground:** keep a bar, but estimate it from bytes read divided by file size. That needs no pre-count. The catch is accuracy. Rows vary in length, so the estimate will drift on files with long notes fields. I don't know yet if it's close enough to be useful. We'd also need to check that getting a byte position works cleanly with how `read_row` reads the text stream.

What do you think? Would a rows-processed counter be enough for the people asking for the bar, or is the percentage what they actually care about? If it's the percentage, I'm happy to prototype the bytes-based estimate on a few real exports so we can see how far off it is before deciding.
