Hey devi, before this merges I'd like to suggest a change to how the progress is computed. I'm not trying to block the branch.

Right now the branch counts every row up front so it can show a percentage, which means we read the whole input twice. On our biggest exports that first counting pass takes a noticeable amount of time on its own. I'll be honest that I haven't timed it, so I can't give you a number yet. I can measure it on one of the large exports if that would help.

**My suggestion:** drop the pre-count and show rows processed and chunks written as we go, instead of a percentage. That gets us back to a single pass. `split_file()` already reads row by row, so this would only touch the CLI side of your branch. The splitting logic stays as it is.

**What we'd lose:** the percentage and the ETA. You've said users ask for the bar, and I don't want to throw that away lightly.

**A possible middle ground:** keep a percentage, but estimate it from bytes read divided by file size. That needs no pre-count and still gives users a bar. The catch is that rows vary in length, so the estimate will be off on files with long notes fields. I don't know yet whether it's close enough to be useful, so I'd want to try it on a few real exports first.

What do you think? Would a rows-processed counter be enough for the users who asked for this, or do they really need the percentage? If they do, is the bytes-based estimate worth trying? I'm happy to pair on whichever way you prefer.
