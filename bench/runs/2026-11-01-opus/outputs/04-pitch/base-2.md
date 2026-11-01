Hi devi, before this merges I'd like to suggest a change to how the progress works. I'm raising it now because it's much easier to change before merge than after.

As I read the branch, it counts every row before splitting so it can show a percentage. That means the whole input gets read twice. On our biggest exports the counting pass alone takes a noticeable amount of time. I haven't actually timed it, so I can't give you a number yet. I can measure it if that would help.

**Proposal:** drop the pre-count and make it a single pass. Instead of a percentage, show live counts of rows processed and chunks written. `split_file()` already reads one row at a time, so this is mostly a change to the CLI side of the branch.

**What we'd lose:** the percentage and the ETA. You've said users ask for the bar, and I'm not dismissing that. It's the main cost here.

**Possible middle ground:** estimate the percentage as bytes read ÷ file size. That doesn't need a pre-count, so we'd keep a bar and still read the file once. The catch is that rows vary in length, so the estimate will be off on files with long notes fields. I don't know how far off it gets in practice. It might be close enough for a progress bar, or it might jump around too much to be useful.

What do you think? You know better than I do what users actually rely on, so I'd value your take, especially on whether a byte-based estimate would satisfy the people who asked for the bar. I'm happy to pair on it or put up a commit against your branch if you want to see what it looks like.
