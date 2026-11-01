Hi devi, thanks for the progress bar work. I have one suggestion to raise before this merges.

**The concern:** the branch counts every row before splitting so it can show a percentage. That means reading the whole input twice. On our biggest exports I expect the first pass alone to take a noticeable while. I haven't timed it, so that's a guess, and I'll measure it if you'd like numbers.

**Proposal:** drop the pre-count and report "rows processed" and chunks written instead of a percentage. That gives one pass over the input. `split_file()` already reads row by row, so the change should be confined to the CLI code in this branch. I'm happy to do that part.

**The tradeoff:** we lose the percentage and the ETA. I know users like the bar and have asked for it, so I don't want to wave that away.

**Middle ground:** estimate progress as bytes read divided by file size. It needs no pre-count, so we'd keep a percentage and stay at one pass. The catch is that rows vary in length, so the estimate will drift on files with long notes. I don't know yet whether it's accurate enough. We could try it on a couple of real exports and see.

Where do you land? If you think the exact percentage matters enough to justify the second pass, I'd like to hear that. I'd also like to measure the pre-count cost on a large export first so we're deciding on data.
