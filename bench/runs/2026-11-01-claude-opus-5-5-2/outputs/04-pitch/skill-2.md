Hi devi, before this merges I'd like to suggest a change to how the progress bar gets its numbers.

Right now the branch counts every row in the input before it starts splitting, so it can show a percentage. That means splitlane reads the whole input twice. On our biggest exports the counting pass alone takes a while. I haven't timed it, so I don't have a number for you yet.

My suggestion is to drop the pre-count and show rows processed and chunks written as the split runs. Then the input is read only once. `split_file()` already reads row by row, so I think the change stays in the CLI code on this branch, though you know that code better than I do.

This does cost something: we'd lose the percentage and the ETA. You've said users ask for the bar, and I don't want to throw that away lightly.

There might be a middle ground. We could estimate the percentage by dividing bytes read by file size, which also needs no pre-count. The catch is that rows vary in length, so the estimate will be off on files with long notes. I don't know yet whether it would be accurate enough for what users want from the bar.

What do you think? Would either of these work for you?
