Hi Devi, the progress bar is a nice addition. I'd like to suggest one change before it merges.

The branch counts every row before splitting so it can show a percentage. That means reading the whole input twice. I haven't timed it, but on our biggest exports I expect the first pass alone to take a noticeable while before any output appears.

**Proposal:** drop the pre-count and make a single pass over the input. The bar would show rows processed and chunks written instead of a percentage. `split_file()` already reads row by row, so the change should be confined to the CLI code in this branch.

**The cost:** there would be no percentage and no ETA. I know users ask for those, so I don't want to wave that away.

**Middle ground:** estimate the percentage as bytes read divided by file size. That needs no pre-count, so it keeps the single pass. I don't know yet whether it's accurate enough. Rows vary in length, so the estimate will drift on files with long notes. We could try it on a few real exports and see how far off it gets.

I'd lean toward the bytes-read estimate if it holds up, and toward rows and chunks if it doesn't. What do you think? I'm happy to pair on it if you'd like.
