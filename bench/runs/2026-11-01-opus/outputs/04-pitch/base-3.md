Hey devi, before this merges I'd like to float an idea about the progress display.

Right now the branch counts every row before splitting so it can show a percentage. That means we read the whole input twice. On our biggest exports that first pass takes a noticeable while. I haven't timed it yet, so I can't give you a number, but it's paying for the whole file just to get the denominator.

**My suggestion:** drop the pre-count and show a running "rows processed / chunks written" counter instead of a percentage. That's one pass over the input. `split_file()` already reads row by row, so I think the change mostly stays in the CLI side of your branch. Correct me if I'm missing something.

**The cost:** no percentage and no ETA. You've said users ask for the bar, and I'm not dismissing that.

**A possible middle ground:** estimate the percentage as bytes read divided by file size. That needs no pre-count. The catch is that rows vary in length, so the estimate will drift on files with long notes fields. I don't know yet whether it's close enough to be useful or just misleading.

Before we choose, I'm happy to time the pre-count on one of the large exports so we know how much it actually costs. I could also try the byte-based estimate on a file with long notes to see how far off it gets. What do you think?

— tomasz
