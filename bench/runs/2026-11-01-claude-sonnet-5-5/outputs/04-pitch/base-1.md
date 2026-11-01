Hey Devi, thanks for the progress bar work. Before this merges, I'd like to pitch a change to how it gets its numbers.

**The concern:** the branch counts every row before splitting so it can show a percentage. That means reading the whole input twice. I haven't timed it, but on our biggest exports the first pass alone takes a noticeable while before anything starts happening.

**The proposal:** drop the pre-count and make it a single pass. `split_file()` already reads row by row, so the change would be confined to the CLI code on this branch. Instead of a percentage, we'd show rows processed and chunks written.

**The tradeoff:** we'd lose the percentage and ETA. I know users like the bar and ask for it, so I don't want to wave that away.

**A middle ground:** estimate progress as bytes read divided by file size. That needs no pre-count and keeps a real percentage. The catch is accuracy. Rows vary in length, so the estimate will drift on files with long notes. I don't know yet if it's good enough to be worth it.

What do you think? If the estimate holds up on a few real exports, I'd lean toward that over a plain counter. I'm happy to try it on a couple of files and share the numbers, or to hear why the exact count matters more than I'm giving it credit for.
